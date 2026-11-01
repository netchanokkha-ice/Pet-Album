import 'package:drift/drift.dart';

import '../database/pawlum_database.dart';
import 'sync_operation.dart';
import 'sync_operation_store.dart';
import 'sync_repository.dart';

class DriftSyncRepository implements SyncRepository {
  const DriftSyncRepository(this._database, this._operationStore);

  final PawlumDatabase _database;
  final SyncOperationStore _operationStore;

  @override
  Future<AccountSyncState> loadState(String accountId) async {
    final rows =
        await (_database.select(_database.syncOperations)
              ..where(
                (SyncOperations table) =>
                    table.accountId.equals(accountId) &
                    table.status.isNotValue(
                      SyncOperationStatus.completed.wireName,
                    ),
              )
              ..orderBy(<OrderClauseGenerator<SyncOperations>>[
                (SyncOperations table) => OrderingTerm.asc(table.createdAt),
              ]))
            .get();
    return AccountSyncState(
      accountId: accountId,
      items: rows.map(_mapRow).toList(growable: false),
    );
  }

  @override
  Future<RetrySyncResult> retry({
    required String accountId,
    required String operationId,
    required DateTime requestedAt,
  }) async {
    final row =
        await (_database.select(_database.syncOperations)..where(
              (SyncOperations table) =>
                  table.accountId.equals(accountId) &
                  table.id.equals(operationId),
            ))
            .getSingleOrNull();
    if (row == null) {
      return RetrySyncResult.notFound;
    }
    if (row.status != SyncOperationStatus.retryWait.wireName) {
      return RetrySyncResult.notRetryable;
    }
    final queued = await _operationStore.requestRetry(
      accountId: accountId,
      operationId: operationId,
      requestedAt: requestedAt,
    );
    return queued ? RetrySyncResult.queued : RetrySyncResult.notRetryable;
  }

  SyncQueueItem _mapRow(SyncOperationRow row) {
    return SyncQueueItem(
      id: row.id,
      aggregateType: row.aggregateType,
      aggregateId: row.aggregateId,
      operationType: row.operationType,
      state: switch (SyncOperationStatus.fromWireName(row.status)) {
        SyncOperationStatus.pending => SyncQueueItemState.pending,
        SyncOperationStatus.running => SyncQueueItemState.running,
        SyncOperationStatus.retryWait => SyncQueueItemState.waitingToRetry,
        SyncOperationStatus.conflict => SyncQueueItemState.conflict,
        SyncOperationStatus.completed => throw StateError(
          'Completed operations are not exposed as active sync work.',
        ),
      },
      attemptCount: row.attemptCount,
      nextRetryAt: row.nextAttemptAt,
      lastErrorCode: row.lastErrorCode,
    );
  }
}
