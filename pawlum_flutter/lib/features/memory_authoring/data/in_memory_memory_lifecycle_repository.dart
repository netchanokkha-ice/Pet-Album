import '../domain/entities/memory_models.dart';
import '../domain/repositories/memory_lifecycle_repository.dart';

class InMemoryMemoryLifecycleRepository implements MemoryLifecycleRepository {
  final Map<String, MemoryAggregate> _memories = <String, MemoryAggregate>{};

  void seed(MemoryAggregate memory) {
    _memories[memory.id] = memory;
  }

  @override
  Future<List<MemoryAggregate>> listActive(String accountId) async {
    final memories = _memories.values
        .where(
          (MemoryAggregate memory) =>
              memory.creatorAccountId == accountId &&
              memory.lifecycleStatus != MemoryLifecycleStatus.softDeleted &&
              memory.lifecycleStatus != MemoryLifecycleStatus.purged,
        )
        .toList(growable: false);
    memories.sort(
      (MemoryAggregate a, MemoryAggregate b) =>
          b.updatedAt.compareTo(a.updatedAt),
    );
    return List<MemoryAggregate>.unmodifiable(memories);
  }

  @override
  Future<List<MemoryAggregate>> listRecoverable({
    required String accountId,
    required DateTime at,
  }) async {
    final memories = _memories.values
        .where(
          (MemoryAggregate memory) =>
              memory.creatorAccountId == accountId &&
              memory.lifecycleStatus == MemoryLifecycleStatus.softDeleted &&
              memory.deletionExpiresAt != null &&
              at.isBefore(memory.deletionExpiresAt!),
        )
        .toList(growable: false);
    memories.sort(
      (MemoryAggregate a, MemoryAggregate b) =>
          b.deletedAt!.compareTo(a.deletedAt!),
    );
    return List<MemoryAggregate>.unmodifiable(memories);
  }

  @override
  Future<MemoryAggregate> softDelete({
    required String accountId,
    required String memoryId,
    required DateTime deletedAt,
  }) async {
    final memory = _owned(accountId, memoryId);
    if (memory.lifecycleStatus == MemoryLifecycleStatus.softDeleted) {
      return memory;
    }
    final deleted = memory.softDelete(deletedAt);
    _memories[memoryId] = deleted;
    return deleted;
  }

  @override
  Future<MemoryAggregate> restore({
    required String accountId,
    required String memoryId,
    required DateTime restoredAt,
  }) async {
    final restored = _owned(accountId, memoryId).restore(restoredAt);
    _memories[memoryId] = restored;
    return restored;
  }

  MemoryAggregate _owned(String accountId, String memoryId) {
    final memory = _memories[memoryId];
    if (memory == null) throw const MemoryNotFoundFailure();
    if (memory.creatorAccountId != accountId) {
      throw const MemoryAccessDeniedFailure();
    }
    return memory;
  }
}
