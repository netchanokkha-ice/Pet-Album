enum SyncOperationStatus {
  pending,
  running,
  retryWait,
  completed,
  conflict;

  String get wireName => switch (this) {
    pending => 'pending',
    running => 'running',
    retryWait => 'retry_wait',
    completed => 'completed',
    conflict => 'conflict',
  };

  static SyncOperationStatus fromWireName(String value) => switch (value) {
    'pending' => pending,
    'running' => running,
    'retry_wait' => retryWait,
    'completed' => completed,
    'conflict' => conflict,
    _ => throw FormatException('Unknown sync operation status: $value'),
  };
}

class SyncOperation {
  const SyncOperation({
    required this.accountId,
    required this.id,
    required this.aggregateType,
    required this.aggregateId,
    required this.operationType,
    required this.idempotencyKey,
    required this.payloadJson,
    required this.dependencyOperationIds,
    required this.status,
    required this.attemptCount,
    required this.createdAt,
    required this.updatedAt,
    this.nextAttemptAt,
    this.lastErrorCode,
    this.remoteRevision,
  });

  final String accountId;
  final String id;
  final String aggregateType;
  final String aggregateId;
  final String operationType;
  final String idempotencyKey;
  final String payloadJson;
  final List<String> dependencyOperationIds;
  final SyncOperationStatus status;
  final int attemptCount;
  final DateTime? nextAttemptAt;
  final String? lastErrorCode;
  final String? remoteRevision;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class SyncOperationDraft {
  const SyncOperationDraft({
    required this.accountId,
    required this.id,
    required this.aggregateType,
    required this.aggregateId,
    required this.operationType,
    required this.commandId,
    required this.createdAt,
    this.payloadJson = '{}',
    this.dependencyOperationIds = const <String>[],
  });

  final String accountId;
  final String id;
  final String aggregateType;
  final String aggregateId;
  final String operationType;
  final String commandId;
  final String payloadJson;
  final List<String> dependencyOperationIds;
  final DateTime createdAt;

  String get idempotencyKey => DeterministicIdempotencyKey.create(
    accountId: accountId,
    aggregateType: aggregateType,
    aggregateId: aggregateId,
    operationType: operationType,
    commandId: commandId,
  );
}

abstract final class DeterministicIdempotencyKey {
  static String create({
    required String accountId,
    required String aggregateType,
    required String aggregateId,
    required String operationType,
    required String commandId,
  }) {
    final segments = <String>[
      accountId,
      aggregateType,
      aggregateId,
      operationType,
      commandId,
    ];
    return 'pawlum:v1:${segments.map(Uri.encodeComponent).join(':')}';
  }
}

class RetryBackoffPolicy {
  const RetryBackoffPolicy({
    this.baseDelay = const Duration(seconds: 2),
    this.maximumDelay = const Duration(minutes: 15),
  });

  final Duration baseDelay;
  final Duration maximumDelay;

  Duration delayForAttempt(int attemptCount) {
    if (attemptCount < 1) {
      throw ArgumentError.value(
        attemptCount,
        'attemptCount',
        'must be at least one',
      );
    }

    var milliseconds = baseDelay.inMilliseconds;
    for (var attempt = 1; attempt < attemptCount; attempt += 1) {
      if (milliseconds >= maximumDelay.inMilliseconds) {
        return maximumDelay;
      }
      milliseconds *= 2;
    }

    return Duration(
      milliseconds: milliseconds.clamp(0, maximumDelay.inMilliseconds),
    );
  }
}
