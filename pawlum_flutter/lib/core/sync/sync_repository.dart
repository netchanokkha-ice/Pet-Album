enum SyncQueueItemState { pending, running, waitingToRetry, conflict }

class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.aggregateType,
    required this.aggregateId,
    required this.operationType,
    required this.state,
    required this.attemptCount,
    this.nextRetryAt,
    this.lastErrorCode,
  });

  final String id;
  final String aggregateType;
  final String aggregateId;
  final String operationType;
  final SyncQueueItemState state;
  final int attemptCount;
  final DateTime? nextRetryAt;
  final String? lastErrorCode;

  SyncQueueItem copyWith({
    SyncQueueItemState? state,
    DateTime? nextRetryAt,
    bool clearNextRetryAt = false,
    String? lastErrorCode,
    bool clearLastErrorCode = false,
  }) {
    return SyncQueueItem(
      id: id,
      aggregateType: aggregateType,
      aggregateId: aggregateId,
      operationType: operationType,
      state: state ?? this.state,
      attemptCount: attemptCount,
      nextRetryAt: clearNextRetryAt ? null : nextRetryAt ?? this.nextRetryAt,
      lastErrorCode: clearLastErrorCode
          ? null
          : lastErrorCode ?? this.lastErrorCode,
    );
  }
}

class AccountSyncState {
  AccountSyncState({
    required this.accountId,
    required List<SyncQueueItem> items,
  }) : items = List<SyncQueueItem>.unmodifiable(items);

  final String accountId;
  final List<SyncQueueItem> items;

  int get pendingCount => items
      .where((SyncQueueItem item) => item.state == SyncQueueItemState.pending)
      .length;

  int get runningCount => items
      .where((SyncQueueItem item) => item.state == SyncQueueItemState.running)
      .length;

  int get failedCount => items
      .where(
        (SyncQueueItem item) => item.state == SyncQueueItemState.waitingToRetry,
      )
      .length;

  int get conflictCount => items
      .where((SyncQueueItem item) => item.state == SyncQueueItemState.conflict)
      .length;

  bool get requiresAttention => failedCount > 0 || conflictCount > 0;
}

enum RetrySyncResult { queued, notFound, notRetryable }

abstract interface class SyncRepository {
  Future<AccountSyncState> loadState(String accountId);

  Future<RetrySyncResult> retry({
    required String accountId,
    required String operationId,
    required DateTime requestedAt,
  });
}
