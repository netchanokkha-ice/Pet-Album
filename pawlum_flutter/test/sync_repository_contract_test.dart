import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pawlum/core/database/pawlum_database.dart';
import 'package:pawlum/core/sync/drift_sync_operation_store.dart';
import 'package:pawlum/core/sync/drift_sync_repository.dart';
import 'package:pawlum/core/sync/in_memory_sync_repository.dart';
import 'package:pawlum/core/sync/sync_operation.dart';
import 'package:pawlum/core/sync/sync_repository.dart';

void main() {
  _runSyncRepositoryContract('in-memory fake', _createFakeHarness);
  _runSyncRepositoryContract('Drift local', _createLocalHarness);
}

void _runSyncRepositoryContract(
  String implementationName,
  Future<_SyncRepositoryHarness> Function() createHarness,
) {
  group('$implementationName SyncRepository contract', () {
    late _SyncRepositoryHarness harness;

    setUp(() async {
      harness = await createHarness();
    });

    tearDown(() async {
      await harness.close();
    });

    test('exposes account-scoped active sync state', () async {
      final state = await harness.repository.loadState('account-a');

      expect(state.accountId, 'account-a');
      expect(state.items.map((SyncQueueItem item) => item.id), <String>[
        'pending-a',
        'failed-a',
        'conflict-a',
      ]);
      expect(state.pendingCount, 1);
      expect(state.runningCount, 0);
      expect(state.failedCount, 1);
      expect(state.conflictCount, 1);
      expect(state.requiresAttention, isTrue);

      final otherAccount = await harness.repository.loadState('account-b');
      expect(otherAccount.items.map((SyncQueueItem item) => item.id), <String>[
        'failed-b',
      ]);
    });

    test('queues retryable failures and rejects unsafe retries', () async {
      final requestedAt = DateTime.utc(2026, 11, 1, 1);

      expect(
        await harness.repository.retry(
          accountId: 'account-a',
          operationId: 'failed-a',
          requestedAt: requestedAt,
        ),
        RetrySyncResult.queued,
      );
      final afterRetry = await harness.repository.loadState('account-a');
      final retried = afterRetry.items.singleWhere(
        (SyncQueueItem item) => item.id == 'failed-a',
      );
      expect(retried.state, SyncQueueItemState.pending);
      expect(retried.nextRetryAt, isNull);
      expect(retried.lastErrorCode, isNull);

      expect(
        await harness.repository.retry(
          accountId: 'account-a',
          operationId: 'failed-a',
          requestedAt: requestedAt,
        ),
        RetrySyncResult.notRetryable,
      );
      expect(
        await harness.repository.retry(
          accountId: 'account-a',
          operationId: 'conflict-a',
          requestedAt: requestedAt,
        ),
        RetrySyncResult.notRetryable,
      );
      expect(
        await harness.repository.retry(
          accountId: 'account-a',
          operationId: 'missing',
          requestedAt: requestedAt,
        ),
        RetrySyncResult.notFound,
      );
    });
  });
}

abstract interface class _SyncRepositoryHarness {
  SyncRepository get repository;

  Future<void> close();
}

class _FakeHarness implements _SyncRepositoryHarness {
  _FakeHarness(this.repository);

  @override
  final SyncRepository repository;

  @override
  Future<void> close() async {}
}

class _LocalHarness implements _SyncRepositoryHarness {
  _LocalHarness(this.repository, this.database, this.tempDirectory);

  @override
  final SyncRepository repository;
  final PawlumDatabase database;
  final Directory tempDirectory;

  @override
  Future<void> close() async {
    await database.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  }
}

Future<_SyncRepositoryHarness> _createFakeHarness() async {
  final nextRetryAt = DateTime.utc(2026, 11, 1, 2);
  return _FakeHarness(
    InMemorySyncRepository(
      seed: <SeededSyncQueueItem>[
        const SeededSyncQueueItem(
          accountId: 'account-a',
          item: SyncQueueItem(
            id: 'pending-a',
            aggregateType: 'media',
            aggregateId: 'media-a',
            operationType: 'upload',
            state: SyncQueueItemState.pending,
            attemptCount: 0,
          ),
        ),
        SeededSyncQueueItem(
          accountId: 'account-a',
          item: SyncQueueItem(
            id: 'failed-a',
            aggregateType: 'memory',
            aggregateId: 'memory-a',
            operationType: 'publish',
            state: SyncQueueItemState.waitingToRetry,
            attemptCount: 1,
            nextRetryAt: nextRetryAt,
            lastErrorCode: 'network_unavailable',
          ),
        ),
        const SeededSyncQueueItem(
          accountId: 'account-a',
          item: SyncQueueItem(
            id: 'conflict-a',
            aggregateType: 'memory',
            aggregateId: 'memory-a',
            operationType: 'promote_edit',
            state: SyncQueueItemState.conflict,
            attemptCount: 0,
            lastErrorCode: 'remote_revision_conflict',
          ),
        ),
        SeededSyncQueueItem(
          accountId: 'account-b',
          item: SyncQueueItem(
            id: 'failed-b',
            aggregateType: 'pet',
            aggregateId: 'pet-b',
            operationType: 'initialize',
            state: SyncQueueItemState.waitingToRetry,
            attemptCount: 1,
            nextRetryAt: nextRetryAt,
            lastErrorCode: 'network_unavailable',
          ),
        ),
      ],
    ),
  );
}

Future<_SyncRepositoryHarness> _createLocalHarness() async {
  final tempDirectory = await Directory.systemTemp.createTemp(
    'pawlum-sync-contract-',
  );
  final database = PawlumDatabase.forTesting(
    NativeDatabase(File(path.join(tempDirectory.path, 'pawlum.sqlite'))),
  );
  final operationStore = DriftSyncOperationStore(database);
  final now = DateTime.utc(2026, 11, 1);

  await _enqueue(
    operationStore,
    id: 'pending-a',
    accountId: 'account-a',
    aggregateType: 'media',
    aggregateId: 'media-a',
    operationType: 'upload',
    createdAt: now,
  );
  await _enqueue(
    operationStore,
    id: 'failed-a',
    accountId: 'account-a',
    aggregateType: 'memory',
    aggregateId: 'memory-a',
    operationType: 'publish',
    createdAt: now.add(const Duration(seconds: 1)),
  );
  await operationStore.markTransientFailure(
    accountId: 'account-a',
    operationId: 'failed-a',
    errorCode: 'network_unavailable',
    failedAt: now.add(const Duration(seconds: 2)),
  );
  await _enqueue(
    operationStore,
    id: 'conflict-a',
    accountId: 'account-a',
    aggregateType: 'memory',
    aggregateId: 'memory-a',
    operationType: 'promote_edit',
    createdAt: now.add(const Duration(seconds: 3)),
  );
  await operationStore.markConflict(
    accountId: 'account-a',
    operationId: 'conflict-a',
    remoteRevision: 'revision-9',
    detectedAt: now.add(const Duration(seconds: 4)),
  );
  await _enqueue(
    operationStore,
    id: 'completed-a',
    accountId: 'account-a',
    aggregateType: 'media',
    aggregateId: 'media-complete',
    operationType: 'upload',
    createdAt: now.add(const Duration(seconds: 5)),
  );
  await operationStore.markCompleted(
    accountId: 'account-a',
    operationId: 'completed-a',
    completedAt: now.add(const Duration(seconds: 6)),
  );
  await _enqueue(
    operationStore,
    id: 'failed-b',
    accountId: 'account-b',
    aggregateType: 'pet',
    aggregateId: 'pet-b',
    operationType: 'initialize',
    createdAt: now.add(const Duration(seconds: 7)),
  );
  await operationStore.markTransientFailure(
    accountId: 'account-b',
    operationId: 'failed-b',
    errorCode: 'network_unavailable',
    failedAt: now.add(const Duration(seconds: 8)),
  );

  return _LocalHarness(
    DriftSyncRepository(database, operationStore),
    database,
    tempDirectory,
  );
}

Future<void> _enqueue(
  DriftSyncOperationStore store, {
  required String id,
  required String accountId,
  required String aggregateType,
  required String aggregateId,
  required String operationType,
  required DateTime createdAt,
}) async {
  await store.enqueue(
    SyncOperationDraft(
      accountId: accountId,
      id: id,
      aggregateType: aggregateType,
      aggregateId: aggregateId,
      operationType: operationType,
      commandId: id,
      createdAt: createdAt,
    ),
  );
}
