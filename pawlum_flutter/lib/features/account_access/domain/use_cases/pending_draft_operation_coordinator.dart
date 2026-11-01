import 'dart:async';

import '../entities/account_session.dart';
import '../repositories/account_repository.dart';

class PendingDraftOperationCoordinator {
  PendingDraftOperationCoordinator({
    required AccountRepository repository,
    required Future<void> Function() requestSignIn,
    required DateTime Function() now,
  }) : this._(repository, requestSignIn, now);

  PendingDraftOperationCoordinator._(
    this._repository,
    this._requestSignIn,
    this._now,
  );

  final AccountRepository _repository;
  final Future<void> Function() _requestSignIn;
  final DateTime Function() _now;
  StreamSubscription<AccountSession>? _subscription;
  Future<void> Function()? _queuedOperation;
  bool _isResuming = false;

  bool get hasQueuedOperation => _queuedOperation != null;

  void start() {
    _subscription ??= _repository.authSessions.listen(
      resumeAfterAuthentication,
    );
  }

  Future<void> runOrQueue({
    required AccountSession? session,
    required Future<void> Function() operation,
  }) async {
    if (session != null && session.canAccessJournalAt(_now())) {
      await operation();
      return;
    }
    _queuedOperation = operation;
    await _requestSignIn();
  }

  Future<void> resumeAfterAuthentication(AccountSession session) async {
    final operation = _queuedOperation;
    if (_isResuming ||
        operation == null ||
        !session.canAccessJournalAt(_now())) {
      return;
    }
    _isResuming = true;
    try {
      await operation();
      _queuedOperation = null;
    } finally {
      _isResuming = false;
    }
  }

  Future<void> close() async => _subscription?.cancel();
}
