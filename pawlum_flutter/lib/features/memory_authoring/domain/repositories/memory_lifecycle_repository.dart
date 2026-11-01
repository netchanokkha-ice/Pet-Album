import '../entities/memory_models.dart';

abstract interface class MemoryLifecycleRepository {
  Future<List<MemoryAggregate>> listActive(String accountId);

  Future<List<MemoryAggregate>> listRecoverable({
    required String accountId,
    required DateTime at,
  });

  Future<MemoryAggregate> softDelete({
    required String accountId,
    required String memoryId,
    required DateTime deletedAt,
  });

  Future<MemoryAggregate> restore({
    required String accountId,
    required String memoryId,
    required DateTime restoredAt,
  });
}

class MemoryNotFoundFailure implements Exception {
  const MemoryNotFoundFailure();
}

class MemoryAccessDeniedFailure implements Exception {
  const MemoryAccessDeniedFailure();
}
