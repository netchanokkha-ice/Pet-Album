import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/pet_models.dart';
import '../../domain/repositories/pet_profile_repository.dart';
import '../supabase_pet_photo_upload_gateway.dart';

class SupabasePetProfileRepository implements PetProfileRepository {
  const SupabasePetProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<PetProfile>> listActivePets(String accountId) async {
    final rows = await _client
        .from('pets')
        .select(_selection)
        .isFilter('deleted_at', null)
        .order('created_at');
    return Future.wait(rows.map(_mapPet));
  }

  @override
  Future<List<PetProfile>> listRecoverableDeletedPets({
    required String accountId,
    required DateTime at,
  }) async {
    final rows = await _client
        .from('pets')
        .select(_selection)
        .not('deleted_at', 'is', null)
        .gt('deletion_expires_at', at.toUtc().toIso8601String())
        .order('deleted_at', ascending: false);
    return Future.wait(rows.map(_mapPet));
  }

  @override
  Future<InitializedPetJournal> initializePetJournal(
    InitializePetJournalCommand command,
  ) {
    throw UnsupportedError(
      'Use the atomic pet onboarding confirmation for initialization.',
    );
  }

  @override
  Future<PetProfile> updateProfile({
    required String accountId,
    required String petId,
    required String name,
    required DateTime updatedAt,
    String? profileImagePath,
    PetType? requestedType,
  }) async {
    final current = await _client
        .from('pets')
        .select('pet_type, profile_image_object_path')
        .eq('id', petId)
        .single();
    if (requestedType != null && current['pet_type'] != requestedType.name) {
      throw const PetTypeImmutableFailure();
    }
    final selectedPath = profileImagePath?.startsWith('http') == true
        ? current['profile_image_object_path'] as String?
        : profileImagePath;
    final row = await _client
        .from('pets')
        .update(<String, Object?>{
          'name': name.trim(),
          'profile_image_object_path': selectedPath,
          'updated_at': updatedAt.toUtc().toIso8601String(),
        })
        .eq('id', petId)
        .select(_selection)
        .single();
    return _mapPet(row);
  }

  @override
  Future<PetProfile> softDeletePet({
    required String accountId,
    required String petId,
    required DateTime deletedAt,
  }) async {
    final row = await _client
        .from('pets')
        .update(<String, Object?>{
          'deleted_at': deletedAt.toUtc().toIso8601String(),
          'deletion_expires_at': deletedAt
              .toUtc()
              .add(const Duration(days: 7))
              .toIso8601String(),
          'updated_at': deletedAt.toUtc().toIso8601String(),
        })
        .eq('id', petId)
        .select(_selection)
        .single();
    return _mapPet(row);
  }

  @override
  Future<PetProfile> restorePet({
    required String accountId,
    required String petId,
    required DateTime restoredAt,
  }) async {
    final row = await _client
        .from('pets')
        .update(<String, Object?>{
          'deleted_at': null,
          'deletion_expires_at': null,
          'updated_at': restoredAt.toUtc().toIso8601String(),
        })
        .eq('id', petId)
        .gt('deletion_expires_at', restoredAt.toUtc().toIso8601String())
        .select(_selection)
        .single();
    return _mapPet(row);
  }

  Future<PetProfile> _mapPet(Map<String, dynamic> row) async {
    final objectPath = row['profile_image_object_path'] as String?;
    final displayPath = objectPath == null
        ? null
        : await _client.storage
              .from(SupabasePetPhotoObjectStore.bucketName)
              .createSignedUrl(objectPath, 3600);
    final deletedAt = _dateTime(row['deleted_at']);
    return PetProfile(
      id: row['id'] as String,
      name: row['name'] as String,
      type: PetType.values.byName(row['pet_type'] as String),
      customTypeLabel: row['custom_type_label'] as String?,
      profileImagePath: displayPath,
      birthday: _dateTime(row['birth_date']),
      firstMetDate: _dateTime(row['first_met_date']),
      status: deletedAt == null
          ? PetLifecycleStatus.active
          : PetLifecycleStatus.softDeleted,
      deletedAt: deletedAt,
      deletionExpiresAt: _dateTime(row['deletion_expires_at']),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  DateTime? _dateTime(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static const String _selection =
      'id, name, pet_type, custom_type_label, profile_image_object_path, '
      'birth_date, first_met_date, created_at, updated_at, deleted_at, '
      'deletion_expires_at';
}
