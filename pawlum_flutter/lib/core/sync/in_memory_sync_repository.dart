import 'sync_repository.dart';

class SeededSyncQueueItem {
  const SeededSyncQueueItem({required this.accountId, required this.item});

  final String accountId;
  final SyncQueueItem item;
}

class InMemorySyncRepository implements SyncRepository {
  InMemorySyncRepository({
    Iterable<SeededSyncQueueItem> seed = const <SeededSyncQueueItem>[],
  }) {
    for (final seeded in seed) {
      _itemsByAccount
          .putIfAbsent(seeded.accountId, () => <SyncQueueItem>[])
          .add(seeded.item);
    }
  }

  final Map<String, List<SyncQueueItem>> _itemsByAccount =
      <String, List<SyncQueueItem>>{};

  @override
  Future<AccountSyncState> loadState(String accountId) async {
    return AccountSyncState(
      accountId: accountId,
      items: _itemsByAccount[accountId] ?? const <SyncQueueItem>[],
    );
  }

  @override
  Future<RetrySyncResult> retry({
    required String accountId,
    required String operationId,
    required DateTime requestedAt,
  }) async {
    final items = _itemsByAccount[accountId];
    if (items == null) {
      return RetrySyncResult.notFound;
    }
    final index = items.indexWhere(
      (SyncQueueItem item) => item.id == operationId,
    );
    if (index < 0) {
      return RetrySyncResult.notFound;
    }
    if (items[index].state != SyncQueueItemState.waitingToRetry) {
      return RetrySyncResult.notRetryable;
    }
    items[index] = items[index].copyWith(
      state: SyncQueueItemState.pending,
      clearNextRetryAt: true,
      clearLastErrorCode: true,
    );
    return RetrySyncResult.queued;
  }
}
