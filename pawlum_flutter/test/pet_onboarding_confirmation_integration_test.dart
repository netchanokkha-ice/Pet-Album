import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pawlum/core/database/pawlum_database.dart';
import 'package:pawlum/core/sync/drift_sync_operation_store.dart';
import 'package:pawlum/core/sync/sync_operation.dart';
import 'package:pawlum/features/pet_profiles/data/data_sources/supabase_pet_journal_gateway.dart';
import 'package:pawlum/features/pet_profiles/data/repositories/drift_pet_onboarding_draft_repository.dart';
import 'package:pawlum/features/pet_profiles/data/supabase_pet_photo_upload_gateway.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_initialization.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_models.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_onboarding_draft.dart';
import 'package:pawlum/features/pet_profiles/domain/repositories/atomic_pet_journal_gateway.dart';
import 'package:pawlum/features/pet_profiles/domain/use_cases/confirm_pet_onboarding.dart';

void main() {
  test(
    'retry creates exactly one complete editable pet journal aggregate',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'pawlum-pet-confirmation-',
      );
      final database = PawlumDatabase.forTesting(
        NativeDatabase(File(path.join(tempDirectory.path, 'pawlum.sqlite'))),
      );
      final drafts = DriftPetOnboardingDraftRepository(database);
      final operations = DriftSyncOperationStore(database);
      final gateway = _InMemoryAtomicGateway(failuresBeforeSuccess: 1);
      final now = DateTime.utc(2026, 11, 1, 4);
      final confirm = ConfirmPetOnboarding(
        gateway,
        operations,
        drafts,
        now: () => now,
      );
      final draft = PetOnboardingDraft(
        accountId: 'account-a',
        id: 'active',
        step: PetOnboardingStep.confirmation,
        name: 'Mochi',
        type: PetType.cat,
        firstMetDate: DateTime.utc(2024, 6, 2),
        updatedAt: now,
      );
      const ids = PetInitializationIds(
        petId: 'pet-1',
        membershipId: 'membership-1',
        memoryId: 'memory-1',
        versionId: 'version-1',
        relationId: 'relation-1',
      );
      final command = PetInitializationCommand(ids: ids, draft: draft);
      await drafts.save(draft);

      expect(await confirm(command), PetInitializationOutcome.pendingRetry);
      expect(await drafts.load('account-a'), isNotNull);
      var operationRows = await database.select(database.syncOperations).get();
      expect(operationRows, hasLength(1));
      expect(
        operationRows.single.status,
        SyncOperationStatus.retryWait.wireName,
      );

      expect(await confirm(command), PetInitializationOutcome.completed);
      expect(await drafts.load('account-a'), isNull);
      expect(gateway.pets, hasLength(1));
      expect(gateway.memberships, hasLength(1));
      expect(gateway.memories, hasLength(1));
      expect(gateway.versions, hasLength(1));
      expect(gateway.relations, hasLength(1));
      expect(gateway.versions.single.editable, isTrue);
      expect(gateway.relations.single.petId, ids.petId);
      expect(gateway.relations.single.memoryId, ids.memoryId);

      expect(await confirm(command), PetInitializationOutcome.completed);
      expect(gateway.pets, hasLength(1));
      expect(gateway.memberships, hasLength(1));
      expect(gateway.relations, hasLength(1));
      operationRows = await database.select(database.syncOperations).get();
      expect(operationRows, hasLength(1));
      expect(
        operationRows.single.status,
        SyncOperationStatus.completed.wireName,
      );

      await database.close();
      await tempDirectory.delete(recursive: true);
    },
  );

  test('Supabase gateway sends the migration RPC parameter contract', () async {
    final rpc = _RecordingRpcClient();
    final gateway = SupabaseAtomicPetJournalGateway(rpc);
    final draft = PetOnboardingDraft(
      accountId: 'account-a',
      id: 'active',
      step: PetOnboardingStep.confirmation,
      name: ' Mochi ',
      type: PetType.other,
      customTypeLabel: ' Hedgehog ',
      firstMetDate: DateTime.utc(2024, 6, 2),
      updatedAt: DateTime.utc(2026, 11, 1),
    );
    const ids = PetInitializationIds(
      petId: 'pet-1',
      membershipId: 'membership-1',
      memoryId: 'memory-1',
      versionId: 'version-1',
      relationId: 'relation-1',
    );

    final result = await gateway.initialize(
      PetInitializationCommand(ids: ids, draft: draft),
    );

    expect(rpc.functionName, 'initialize_pet_journal');
    expect(rpc.parameters['p_pet_id'], ids.petId);
    expect(rpc.parameters['p_membership_id'], ids.membershipId);
    expect(rpc.parameters['p_relation_id'], ids.relationId);
    expect(rpc.parameters['p_name'], 'Mochi');
    expect(rpc.parameters['p_pet_type'], 'other');
    expect(rpc.parameters['p_custom_type_label'], 'Hedgehog');
    expect(rpc.parameters['p_first_memory_date'], '2024-06-02');
    expect(result.workingVersionId, ids.versionId);
  });

  test('pet photo upload uses a stable private owner path', () async {
    final store = _RecordingPetPhotoObjectStore();
    final gateway = SupabasePetPhotoUploadGateway(store);
    final draft = PetOnboardingDraft(
      accountId: 'account-a',
      id: 'draft-a',
      step: PetOnboardingStep.confirmation,
      name: 'Mochi',
      type: PetType.cat,
      profileImageBytes: Uint8List.fromList(<int>[1, 2, 3]),
      profileImageFileName: 'mochi.png',
      profileImageMimeType: 'image/png',
      updatedAt: DateTime.utc(2026, 11, 1),
    );

    final objectPath = await gateway.upload(draft: draft, petId: 'pet-a');

    expect(objectPath, 'account-a/pet-a/profile/draft-a.png');
    expect(store.objectPath, objectPath);
    expect(store.bytes, <int>[1, 2, 3]);
    expect(store.mimeType, 'image/png');
  });
}

class _RecordingPetPhotoObjectStore implements PetPhotoObjectStore {
  String? objectPath;
  Uint8List? bytes;
  String? mimeType;

  @override
  Future<void> upload({
    required String objectPath,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    this.objectPath = objectPath;
    this.bytes = bytes;
    this.mimeType = mimeType;
  }
}

class _InMemoryAtomicGateway implements AtomicPetJournalGateway {
  _InMemoryAtomicGateway({required this.failuresBeforeSuccess});

  int failuresBeforeSuccess;
  final List<String> pets = <String>[];
  final List<String> memberships = <String>[];
  final List<String> memories = <String>[];
  final List<_EditableVersion> versions = <_EditableVersion>[];
  final List<_PetMemoryRelation> relations = <_PetMemoryRelation>[];

  @override
  Future<PetInitializationResult> initialize(
    PetInitializationCommand command,
  ) async {
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess -= 1;
      throw const PetInitializationTransientFailure('network_unavailable');
    }
    if (pets.contains(command.ids.petId)) {
      return PetInitializationResult(
        petId: command.ids.petId,
        memoryId: command.ids.memoryId,
        workingVersionId: command.ids.versionId,
        replayed: true,
      );
    }
    pets.add(command.ids.petId);
    memberships.add(command.ids.membershipId);
    memories.add(command.ids.memoryId);
    versions.add(_EditableVersion(id: command.ids.versionId, editable: true));
    relations.add(
      _PetMemoryRelation(
        id: command.ids.relationId,
        petId: command.ids.petId,
        memoryId: command.ids.memoryId,
      ),
    );
    return PetInitializationResult(
      petId: command.ids.petId,
      memoryId: command.ids.memoryId,
      workingVersionId: command.ids.versionId,
      replayed: false,
    );
  }
}

class _EditableVersion {
  const _EditableVersion({required this.id, required this.editable});

  final String id;
  final bool editable;
}

class _PetMemoryRelation {
  const _PetMemoryRelation({
    required this.id,
    required this.petId,
    required this.memoryId,
  });

  final String id;
  final String petId;
  final String memoryId;
}

class _RecordingRpcClient implements PetJournalRpcClient {
  String? functionName;
  Map<String, Object?> parameters = <String, Object?>{};

  @override
  Future<Object?> call(
    String functionName,
    Map<String, Object?> parameters,
  ) async {
    this.functionName = functionName;
    this.parameters = parameters;
    return <String, Object?>{
      'pet_id': parameters['p_pet_id'],
      'memory_id': parameters['p_memory_id'],
      'working_version_id': parameters['p_version_id'],
      'replayed': false,
    };
  }
}
