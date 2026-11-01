import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/pet_initialization.dart';
import '../../domain/repositories/atomic_pet_journal_gateway.dart';

abstract interface class PetJournalRpcClient {
  Future<Object?> call(String functionName, Map<String, Object?> parameters);
}

class SupabasePetJournalRpcClient implements PetJournalRpcClient {
  const SupabasePetJournalRpcClient(this._client);

  final SupabaseClient _client;

  @override
  Future<Object?> call(String functionName, Map<String, Object?> parameters) {
    return _client.rpc(functionName, params: parameters);
  }
}

class SupabaseAtomicPetJournalGateway implements AtomicPetJournalGateway {
  const SupabaseAtomicPetJournalGateway(this._rpc);

  final PetJournalRpcClient _rpc;

  @override
  Future<PetInitializationResult> initialize(
    PetInitializationCommand command,
  ) async {
    final draft = command.draft;
    final Object? response;
    try {
      response = await _rpc.call('initialize_pet_journal', <String, Object?>{
        'p_pet_id': command.ids.petId,
        'p_membership_id': command.ids.membershipId,
        'p_memory_id': command.ids.memoryId,
        'p_version_id': command.ids.versionId,
        'p_relation_id': command.ids.relationId,
        'p_name': draft.name.trim(),
        'p_pet_type': draft.type?.name,
        'p_custom_type_label': draft.customTypeLabel?.trim(),
        'p_profile_image_object_path': draft.profileImagePath,
        'p_birth_date': _dateOnly(draft.birthday),
        'p_first_met_date': _dateOnly(draft.firstMetDate),
        'p_first_memory_title': 'First day with ${draft.name.trim()}',
        'p_first_memory_date': _dateOnly(
          draft.firstMetDate ?? draft.birthday ?? draft.updatedAt,
        ),
      });
    } on PostgrestException {
      rethrow;
    } on Object {
      throw const PetInitializationTransientFailure('network_unavailable');
    }
    if (response is! Map<Object?, Object?>) {
      throw const FormatException(
        'Pet initialization RPC returned invalid data.',
      );
    }
    return PetInitializationResult(
      petId: _requiredString(response, 'pet_id'),
      memoryId: _requiredString(response, 'memory_id'),
      workingVersionId: _requiredString(response, 'working_version_id'),
      replayed: response['replayed'] == true,
    );
  }

  String? _dateOnly(DateTime? value) {
    if (value == null) return null;
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String _requiredString(Map<Object?, Object?> response, String key) {
    final value = response[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('Pet initialization RPC omitted $key.');
    }
    return value;
  }
}
