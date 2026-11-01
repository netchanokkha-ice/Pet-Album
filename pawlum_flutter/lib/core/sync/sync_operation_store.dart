import 'sync_operation.dart';

abstract interface class SyncOperationStore {
  Future<SyncOperation> enqueue(SyncOperationDraft draft);

  Future<List<SyncOperation>> readyOperations({
    required String accountId,
    required DateTime now,
    int limit = 20,
  });

  Future<void> markRunning({
    required String accountId,
    required String operationId,
    required DateTime startedAt,
  });

  Future<void> markTransientFailure({
    required String accountId,
    required String operationId,
    required String errorCode,
    required DateTime failedAt,
  });

  Future<void> markConflict({
    required String accountId,
    required String operationId,
    required String remoteRevision,
    required DateTime detectedAt,
  });

  Future<void> markCompleted({
    required String accountId,
    required String operationId,
    required DateTime completedAt,
    String? remoteRevision,
  });

  Future<bool> requestRetry({
    required String accountId,
    required String operationId,
    required DateTime requestedAt,
  });

  Future<int> recoverInterrupted({
    required String accountId,
    required DateTime recoveredAt,
  });

  Future<int> cleanupCompleted(String accountId);
}
