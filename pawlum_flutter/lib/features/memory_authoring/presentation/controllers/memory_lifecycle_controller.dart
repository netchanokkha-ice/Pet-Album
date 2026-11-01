import 'dart:async';

import 'package:get/get.dart';

import '../../../account_access/domain/entities/account_session.dart';
import '../../../account_access/domain/failures/account_failure.dart';
import '../../../account_access/domain/repositories/account_repository.dart';
import '../../domain/entities/memory_models.dart';
import '../../domain/repositories/memory_lifecycle_repository.dart';

class MemoryLifecycleController extends GetxController {
  MemoryLifecycleController(
    this._repository,
    this._accountRepository, {
    required this.now,
    this.onMemoryHidden,
    this.onMemoryRestored,
  });

  final MemoryLifecycleRepository _repository;
  final AccountRepository _accountRepository;
  final DateTime Function() now;
  final void Function(String memoryId)? onMemoryHidden;
  final void Function(String memoryId)? onMemoryRestored;

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final active = <MemoryAggregate>[].obs;
  final deleted = <MemoryAggregate>[].obs;
  final busyMemoryId = RxnString();
  MemoryAggregate? _lastDeleted;
  String? _accountId;

  @override
  void onReady() {
    super.onReady();
    unawaited(load());
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _accountRepository.restoreSession();
      final session = switch (result) {
        AccountSuccess<AccountSession?>(value: final value) => value,
        _ => null,
      };
      if (session == null) throw StateError('No active account session.');
      _accountId = session.account.id;
      final values = await Future.wait(<Future<List<MemoryAggregate>>>[
        _repository.listActive(session.account.id),
        _repository.listRecoverable(accountId: session.account.id, at: now()),
      ]);
      active.assignAll(values[0]);
      deleted.assignAll(values[1]);
    } on Object {
      errorMessage.value = 'We could not load memory lifecycle state.';
    } finally {
      isLoading.value = false;
    }
  }

  String titleOf(MemoryAggregate memory) =>
      (memory.currentPublishedVersion ?? memory.currentWorkingVersion)?.title ??
      'Untitled memory';

  MemoryAggregate? activeMemory(String memoryId) => active.firstWhereOrNull(
    (MemoryAggregate memory) => memory.id == memoryId,
  );

  String deleteWarning(MemoryAggregate memory) => memory.isFirstMemory
      ? 'This is the first memory in this pet journal. Deleting it will not '
            'delete the pet profile, and you can restore the memory for seven days.'
      : 'This memory will leave the active timeline. You can restore it for seven days.';

  int daysRemaining(MemoryAggregate memory) {
    final expiresAt = memory.deletionExpiresAt;
    if (expiresAt == null) return 0;
    final seconds = expiresAt.difference(now()).inSeconds;
    if (seconds <= 0) return 0;
    return (seconds / Duration.secondsPerDay).ceil();
  }

  Future<bool> softDelete(MemoryAggregate memory) async {
    final accountId = _accountId;
    if (accountId == null || busyMemoryId.value != null) return false;
    busyMemoryId.value = memory.id;
    errorMessage.value = null;
    try {
      final result = await _repository.softDelete(
        accountId: accountId,
        memoryId: memory.id,
        deletedAt: now(),
      );
      active.removeWhere((MemoryAggregate item) => item.id == memory.id);
      deleted.insert(0, result);
      _lastDeleted = result;
      onMemoryHidden?.call(memory.id);
      return true;
    } on Object {
      errorMessage.value = 'We could not delete this memory.';
      return false;
    } finally {
      busyMemoryId.value = null;
    }
  }

  Future<bool> undoLastDelete() async {
    final memory = _lastDeleted;
    if (memory == null) return false;
    final restored = await restore(memory);
    if (restored) _lastDeleted = null;
    return restored;
  }

  Future<bool> restore(MemoryAggregate memory) async {
    final accountId = _accountId;
    if (accountId == null || busyMemoryId.value != null) return false;
    busyMemoryId.value = memory.id;
    errorMessage.value = null;
    try {
      final result = await _repository.restore(
        accountId: accountId,
        memoryId: memory.id,
        restoredAt: now(),
      );
      deleted.removeWhere((MemoryAggregate item) => item.id == memory.id);
      active.insert(0, result);
      onMemoryRestored?.call(memory.id);
      return true;
    } on MemoryDeletionExpiredFailure {
      deleted.removeWhere((MemoryAggregate item) => item.id == memory.id);
      errorMessage.value = 'This memory is no longer available to restore.';
      return false;
    } on Object {
      errorMessage.value = 'We could not restore this memory.';
      return false;
    } finally {
      busyMemoryId.value = null;
    }
  }
}
