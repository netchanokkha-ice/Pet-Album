import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/core/database/pawlum_database.dart';
import 'package:pawlum/core/sync/drift_sync_operation_store.dart';
import 'package:pawlum/core/sync/sync_operation.dart';

void main() {
  late Directory tempDirectory;
  late File databaseFile;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('pawlum-sync-test-');
    databaseFile = File(
      '${tempDirectory.path}${Platform.pathSeparator}pawlum.sqlite',
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'restart recovers an interrupted upload before its dependent publish',
    () async {
      final now = DateTime.utc(2026, 10, 31, 12);
      final firstDatabase = _openDatabase(databaseFile);
      final firstStore = DriftSyncOperationStore(firstDatabase);
      final upload = await firstStore.enqueue(
        SyncOperationDraft(
          accountId: 'account-a',
          id: 'upload-1',
          aggregateType: 'media',
          aggregateId: 'media-1',
          operationType: 'upload',
          commandId: 'checksum-1',
          payloadJson: '{"localPath":"/private/media-1.jpg"}',
          createdAt: now,
        ),
      );
      await firstStore.enqueue(
        SyncOperationDraft(
          accountId: 'account-a',
          id: 'publish-1',
          aggregateType: 'memory',
          aggregateId: 'memory-1',
          operationType: 'publish',
          commandId: 'version-1',
          dependencyOperationIds: <String>[upload.id],
          createdAt: now.add(const Duration(seconds: 1)),
        ),
      );
      await firstStore.markRunning(
        accountId: 'account-a',
        operationId: upload.id,
        startedAt: now.add(const Duration(seconds: 2)),
      );
      await firstDatabase.close();

      final secondDatabase = _openDatabase(databaseFile);
      final secondStore = DriftSyncOperationStore(secondDatabase);
      expect(
        await secondStore.recoverInterrupted(
          accountId: 'account-a',
          recoveredAt: now.add(const Duration(minutes: 1)),
        ),
        1,
      );
      expect(
        (await secondStore.readyOperations(
          accountId: 'account-a',
          now: now.add(const Duration(minutes: 1)),
        )).map((SyncOperation operation) => operation.id),
        <String>['upload-1'],
      );

      await secondStore.markCompleted(
        accountId: 'account-a',
        operationId: upload.id,
        completedAt: now.add(const Duration(minutes: 2)),
        remoteRevision: 'object-etag-1',
      );
      expect(
        (await secondStore.readyOperations(
          accountId: 'account-a',
          now: now.add(const Duration(minutes: 2)),
        )).map((SyncOperation operation) => operation.id),
        <String>['publish-1'],
      );

      await secondDatabase.close();
    },
  );

  test(
    'duplicate retry reuses its deterministic operation and backoff',
    () async {
      final now = DateTime.utc(2026, 10, 31, 13);
      final database = _openDatabase(databaseFile);
      final store = DriftSyncOperationStore(
        database,
        backoffPolicy: const RetryBackoffPolicy(
          baseDelay: Duration(seconds: 3),
          maximumDelay: Duration(seconds: 30),
        ),
      );
      final original = await store.enqueue(
        SyncOperationDraft(
          accountId: 'account-a',
          id: 'operation-original',
          aggregateType: 'memory',
          aggregateId: 'memory-1',
          operationType: 'publish',
          commandId: 'version-1',
          createdAt: now,
        ),
      );
      final duplicate = await store.enqueue(
        SyncOperationDraft(
          accountId: 'account-a',
          id: 'operation-duplicate',
          aggregateType: 'memory',
          aggregateId: 'memory-1',
          operationType: 'publish',
          commandId: 'version-1',
          createdAt: now.add(const Duration(seconds: 1)),
        ),
      );

      expect(duplicate.id, original.id);
      expect(duplicate.idempotencyKey, original.idempotencyKey);
      expect(
        await database.select(database.syncOperations).get(),
        hasLength(1),
      );

      await store.markRunning(
        accountId: 'account-a',
        operationId: original.id,
        startedAt: now.add(const Duration(seconds: 2)),
      );
      await store.markTransientFailure(
        accountId: 'account-a',
        operationId: original.id,
        errorCode: 'network_unavailable',
        failedAt: now.add(const Duration(seconds: 3)),
      );

      expect(
        await store.readyOperations(
          accountId: 'account-a',
          now: now.add(const Duration(seconds: 5)),
        ),
        isEmpty,
      );
      final retry = await store.readyOperations(
        accountId: 'account-a',
        now: now.add(const Duration(seconds: 6)),
      );
      expect(retry.single.id, original.id);
      expect(retry.single.attemptCount, 1);
      expect(retry.single.lastErrorCode, 'network_unavailable');

      await database.close();
    },
  );

  test(
    'completed cleanup retains dependencies until dependents finish',
    () async {
      final now = DateTime.utc(2026, 10, 31, 14);
      final database = _openDatabase(databaseFile);
      final store = DriftSyncOperationStore(database);
      final upload = await store.enqueue(
        SyncOperationDraft(
          accountId: 'account-a',
          id: 'upload-1',
          aggregateType: 'media',
          aggregateId: 'media-1',
          operationType: 'upload',
          commandId: 'checksum-1',
          createdAt: now,
        ),
      );
      final publish = await store.enqueue(
        SyncOperationDraft(
          accountId: 'account-a',
          id: 'publish-1',
          aggregateType: 'memory',
          aggregateId: 'memory-1',
          operationType: 'publish',
          commandId: 'version-1',
          dependencyOperationIds: <String>[upload.id],
          createdAt: now.add(const Duration(seconds: 1)),
        ),
      );
      await store.markCompleted(
        accountId: 'account-a',
        operationId: upload.id,
        completedAt: now.add(const Duration(seconds: 2)),
      );

      expect(await store.cleanupCompleted('account-a'), 0);

      await store.markCompleted(
        accountId: 'account-a',
        operationId: publish.id,
        completedAt: now.add(const Duration(seconds: 3)),
      );
      expect(await store.cleanupCompleted('account-a'), 2);
      expect(await database.select(database.syncOperations).get(), isEmpty);

      await database.close();
    },
  );

  test(
    'remote revision conflict preserves the local payload after restart',
    () async {
      final now = DateTime.utc(2026, 10, 31, 15);
      final firstDatabase = _openDatabase(databaseFile);
      final firstStore = DriftSyncOperationStore(firstDatabase);
      final operation = await firstStore.enqueue(
        SyncOperationDraft(
          accountId: 'account-a',
          id: 'edit-1',
          aggregateType: 'memory',
          aggregateId: 'memory-1',
          operationType: 'promote_edit',
          commandId: 'edit-version-2',
          payloadJson: '{"title":"Keep this local title"}',
          createdAt: now,
        ),
      );
      await firstStore.markConflict(
        accountId: 'account-a',
        operationId: operation.id,
        remoteRevision: 'remote-revision-9',
        detectedAt: now.add(const Duration(seconds: 1)),
      );
      await firstDatabase.close();

      final secondDatabase = _openDatabase(databaseFile);
      final row = await secondDatabase
          .select(secondDatabase.syncOperations)
          .getSingle();
      final secondStore = DriftSyncOperationStore(secondDatabase);

      expect(row.status, SyncOperationStatus.conflict.wireName);
      expect(row.payloadJson, '{"title":"Keep this local title"}');
      expect(row.remoteRevision, 'remote-revision-9');
      expect(row.lastErrorCode, 'remote_revision_conflict');
      expect(
        await secondStore.readyOperations(accountId: 'account-a', now: now),
        isEmpty,
      );

      await secondDatabase.close();
    },
  );
}

PawlumDatabase _openDatabase(File file) {
  return PawlumDatabase.forTesting(NativeDatabase(file));
}
