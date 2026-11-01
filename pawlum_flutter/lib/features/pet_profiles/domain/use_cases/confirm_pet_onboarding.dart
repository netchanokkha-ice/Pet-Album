import 'dart:convert';

import '../../../../core/sync/sync_operation.dart';
import '../../../../core/sync/sync_operation_store.dart';
import '../entities/pet_initialization.dart';
import '../repositories/atomic_pet_journal_gateway.dart';
import '../repositories/pet_onboarding_draft_repository.dart';

class ConfirmPetOnboarding {
  const ConfirmPetOnboarding(
    this._gateway,
    this._operationStore,
    this._draftRepository, {
    required this.now,
  });

  final AtomicPetJournalGateway _gateway;
  final SyncOperationStore _operationStore;
  final PetOnboardingDraftRepository _draftRepository;
  final DateTime Function() now;

  Future<PetInitializationOutcome> call(
    PetInitializationCommand command,
  ) async {
    final operation = await _operationStore.enqueue(
      SyncOperationDraft(
        accountId: command.draft.accountId,
        id: 'initialize-pet-${command.ids.petId}',
        aggregateType: 'pet',
        aggregateId: command.ids.petId,
        operationType: 'initialize_pet_journal',
        commandId: command.ids.petId,
        payloadJson: _encodePayload(command),
        createdAt: now(),
      ),
    );
    await _operationStore.markRunning(
      accountId: command.draft.accountId,
      operationId: operation.id,
      startedAt: now(),
    );
    try {
      final result = await _gateway.initialize(command);
      await _operationStore.markCompleted(
        accountId: command.draft.accountId,
        operationId: operation.id,
        completedAt: now(),
        remoteRevision: result.workingVersionId,
      );
      await _draftRepository.clear(command.draft.accountId);
      return PetInitializationOutcome.completed;
    } on PetInitializationTransientFailure catch (failure) {
      await _operationStore.markTransientFailure(
        accountId: command.draft.accountId,
        operationId: operation.id,
        errorCode: failure.code,
        failedAt: now(),
      );
      return PetInitializationOutcome.pendingRetry;
    }
  }

  String _encodePayload(PetInitializationCommand command) {
    return jsonEncode(<String, Object?>{
      'petId': command.ids.petId,
      'membershipId': command.ids.membershipId,
      'memoryId': command.ids.memoryId,
      'versionId': command.ids.versionId,
      'relationId': command.ids.relationId,
      'name': command.draft.name,
      'petType': command.draft.type?.name,
      'customTypeLabel': command.draft.customTypeLabel,
      'profileImagePath': command.draft.profileImagePath,
      'birthday': command.draft.birthday?.toIso8601String(),
      'firstMetDate': command.draft.firstMetDate?.toIso8601String(),
    });
  }
}
