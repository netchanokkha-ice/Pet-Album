import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/pawlum_database.dart';
import 'sync_operation.dart';
import 'sync_operation_store.dart';

class DriftSyncOperationStore implements SyncOperationStore {
  DriftSyncOperationStore(
    this._database, {
    this.backoffPolicy = const RetryBackoffPolicy(),
  });

  final PawlumDatabase _database;
  final RetryBackoffPolicy backoffPolicy;

  @override
  Future<SyncOperation> enqueue(SyncOperationDraft draft) {
    return _database.transaction(() async {
      final existing =
          await (_database.select(_database.syncOperations)..where(
                (SyncOperations table) =>
                    table.accountId.equals(draft.accountId) &
                    table.idempotencyKey.equals(draft.idempotencyKey),
              ))
              .getSingleOrNull();
      if (existing != null) {
        return _mapRow(existing);
      }

      await _database
          .into(_database.syncOperations)
          .insert(
            SyncOperationsCompanion.insert(
              accountId: draft.accountId,
              id: draft.id,
              aggregateType: draft.aggregateType,
              aggregateId: draft.aggregateId,
              operationType: draft.operationType,
              idempotencyKey: draft.idempotencyKey,
              payloadJson: Value<String>(draft.payloadJson),
              dependencyIdsJson: Value<String>(
                jsonEncode(draft.dependencyOperationIds),
              ),
              createdAt: draft.createdAt,
              updatedAt: draft.createdAt,
            ),
          );

      return SyncOperation(
        accountId: draft.accountId,
        id: draft.id,
        aggregateType: draft.aggregateType,
        aggregateId: draft.aggregateId,
        operationType: draft.operationType,
        idempotencyKey: draft.idempotencyKey,
        payloadJson: draft.payloadJson,
        dependencyOperationIds: List<String>.unmodifiable(
          draft.dependencyOperationIds,
        ),
        status: SyncOperationStatus.pending,
        attemptCount: 0,
        createdAt: draft.createdAt,
        updatedAt: draft.createdAt,
      );
    });
  }

  @override
  Future<List<SyncOperation>> readyOperations({
    required String accountId,
    required DateTime now,
    int limit = 20,
  }) async {
    if (limit < 1) {
      return const <SyncOperation>[];
    }

    final rows =
        await (_database.select(_database.syncOperations)
              ..where(
                (SyncOperations table) => table.accountId.equals(accountId),
              )
              ..orderBy(<OrderClauseGenerator<SyncOperations>>[
                (SyncOperations table) => OrderingTerm.asc(table.createdAt),
              ]))
            .get();
    final rowsById = <String, SyncOperationRow>{
      for (final row in rows) row.id: row,
    };

    final ready = <SyncOperation>[];
    for (final row in rows) {
      final status = SyncOperationStatus.fromWireName(row.status);
      final retryIsDue =
          row.nextAttemptAt == null || !row.nextAttemptAt!.isAfter(now);
      final canRun =
          status == SyncOperationStatus.pending ||
          (status == SyncOperationStatus.retryWait && retryIsDue);
      if (!canRun) {
        continue;
      }

      final dependenciesComplete = _decodeDependencies(row.dependencyIdsJson)
          .every((String dependencyId) {
            final dependency = rowsById[dependencyId];
            return dependency == null ||
                dependency.status == SyncOperationStatus.completed.wireName;
          });
      if (!dependenciesComplete) {
        continue;
      }

      ready.add(_mapRow(row));
      if (ready.length == limit) {
        break;
      }
    }
    return ready;
  }

  @override
  Future<void> markRunning({
    required String accountId,
    required String operationId,
    required DateTime startedAt,
  }) async {
    await _writeExisting(
      accountId: accountId,
      operationId: operationId,
      companion: SyncOperationsCompanion(
        status: Value<String>(SyncOperationStatus.running.wireName),
        nextAttemptAt: const Value<DateTime?>(null),
        updatedAt: Value<DateTime>(startedAt),
      ),
    );
  }

  @override
  Future<void> markTransientFailure({
    required String accountId,
    required String operationId,
    required String errorCode,
    required DateTime failedAt,
  }) async {
    final operation = await _requireRow(accountId, operationId);
    final nextAttemptCount = operation.attemptCount + 1;
    final nextAttemptAt = failedAt.add(
      backoffPolicy.delayForAttempt(nextAttemptCount),
    );
    await _writeExisting(
      accountId: accountId,
      operationId: operationId,
      companion: SyncOperationsCompanion(
        status: Value<String>(SyncOperationStatus.retryWait.wireName),
        attemptCount: Value<int>(nextAttemptCount),
        nextAttemptAt: Value<DateTime?>(nextAttemptAt),
        lastErrorCode: Value<String?>(errorCode),
        updatedAt: Value<DateTime>(failedAt),
      ),
    );
  }

  @override
  Future<void> markConflict({
    required String accountId,
    required String operationId,
    required String remoteRevision,
    required DateTime detectedAt,
  }) async {
    await _writeExisting(
      accountId: accountId,
      operationId: operationId,
      companion: SyncOperationsCompanion(
        status: Value<String>(SyncOperationStatus.conflict.wireName),
        nextAttemptAt: const Value<DateTime?>(null),
        lastErrorCode: const Value<String?>('remote_revision_conflict'),
        remoteRevision: Value<String?>(remoteRevision),
        updatedAt: Value<DateTime>(detectedAt),
      ),
    );
  }

  @override
  Future<void> markCompleted({
    required String accountId,
    required String operationId,
    required DateTime completedAt,
    String? remoteRevision,
  }) async {
    await _writeExisting(
      accountId: accountId,
      operationId: operationId,
      companion: SyncOperationsCompanion(
        status: Value<String>(SyncOperationStatus.completed.wireName),
        nextAttemptAt: const Value<DateTime?>(null),
        lastErrorCode: const Value<String?>(null),
        remoteRevision: Value<String?>(remoteRevision),
        updatedAt: Value<DateTime>(completedAt),
      ),
    );
  }

  @override
  Future<bool> requestRetry({
    required String accountId,
    required String operationId,
    required DateTime requestedAt,
  }) async {
    final updated =
        await (_database.update(_database.syncOperations)..where(
              (SyncOperations table) =>
                  table.accountId.equals(accountId) &
                  table.id.equals(operationId) &
                  table.status.equals(SyncOperationStatus.retryWait.wireName),
            ))
            .write(
              SyncOperationsCompanion(
                status: Value<String>(SyncOperationStatus.pending.wireName),
                nextAttemptAt: const Value<DateTime?>(null),
                lastErrorCode: const Value<String?>(null),
                updatedAt: Value<DateTime>(requestedAt),
              ),
            );
    return updated == 1;
  }

  @override
  Future<int> recoverInterrupted({
    required String accountId,
    required DateTime recoveredAt,
  }) {
    return (_database.update(_database.syncOperations)..where(
          (SyncOperations table) =>
              table.accountId.equals(accountId) &
              table.status.equals(SyncOperationStatus.running.wireName),
        ))
        .write(
          SyncOperationsCompanion(
            status: Value<String>(SyncOperationStatus.pending.wireName),
            updatedAt: Value<DateTime>(recoveredAt),
          ),
        );
  }

  @override
  Future<int> cleanupCompleted(String accountId) {
    return _database.transaction(() async {
      final rows =
          await (_database.select(_database.syncOperations)..where(
                (SyncOperations table) => table.accountId.equals(accountId),
              ))
              .get();
      final retainedDependencyIds = rows
          .where(
            (SyncOperationRow row) =>
                row.status != SyncOperationStatus.completed.wireName,
          )
          .expand(
            (SyncOperationRow row) =>
                _decodeDependencies(row.dependencyIdsJson),
          )
          .toSet();
      final removableIds = rows
          .where(
            (SyncOperationRow row) =>
                row.status == SyncOperationStatus.completed.wireName &&
                !retainedDependencyIds.contains(row.id),
          )
          .map((SyncOperationRow row) => row.id)
          .toList(growable: false);

      var deleted = 0;
      for (final operationId in removableIds) {
        deleted +=
            await (_database.delete(_database.syncOperations)..where(
                  (SyncOperations table) =>
                      table.accountId.equals(accountId) &
                      table.id.equals(operationId),
                ))
                .go();
      }
      return deleted;
    });
  }

  Future<SyncOperationRow> _requireRow(
    String accountId,
    String operationId,
  ) async {
    final row =
        await (_database.select(_database.syncOperations)..where(
              (SyncOperations table) =>
                  table.accountId.equals(accountId) &
                  table.id.equals(operationId),
            ))
            .getSingleOrNull();
    if (row == null) {
      throw StateError('Sync operation not found in the account scope.');
    }
    return row;
  }

  Future<void> _writeExisting({
    required String accountId,
    required String operationId,
    required SyncOperationsCompanion companion,
  }) async {
    await _requireRow(accountId, operationId);
    await (_database.update(_database.syncOperations)..where(
          (SyncOperations table) =>
              table.accountId.equals(accountId) & table.id.equals(operationId),
        ))
        .write(companion);
  }

  SyncOperation _mapRow(SyncOperationRow row) {
    return SyncOperation(
      accountId: row.accountId,
      id: row.id,
      aggregateType: row.aggregateType,
      aggregateId: row.aggregateId,
      operationType: row.operationType,
      idempotencyKey: row.idempotencyKey,
      payloadJson: row.payloadJson,
      dependencyOperationIds: List<String>.unmodifiable(
        _decodeDependencies(row.dependencyIdsJson),
      ),
      status: SyncOperationStatus.fromWireName(row.status),
      attemptCount: row.attemptCount,
      nextAttemptAt: row.nextAttemptAt,
      lastErrorCode: row.lastErrorCode,
      remoteRevision: row.remoteRevision,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  List<String> _decodeDependencies(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! List<Object?>) {
      throw const FormatException('Sync dependency payload must be a list.');
    }
    return decoded
        .map((Object? value) {
          if (value is! String) {
            throw const FormatException('Sync dependency ID must be a string.');
          }
          return value;
        })
        .toList(growable: false);
  }
}
