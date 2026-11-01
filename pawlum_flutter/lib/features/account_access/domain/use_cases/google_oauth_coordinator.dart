import 'dart:async';

import '../entities/account_identity.dart';
import '../entities/account_session.dart';
import '../failures/account_failure.dart';
import '../repositories/account_repository.dart';

class GoogleOAuthCoordinator {
  GoogleOAuthCoordinator({
    required AccountRepository repository,
    required Future<void> Function(AccountSession session) onAuthenticated,
  }) : this._(repository, onAuthenticated);

  GoogleOAuthCoordinator._(this._repository, this._onAuthenticated);

  final AccountRepository _repository;
  final Future<void> Function(AccountSession session) _onAuthenticated;
  final Set<String> _handledAccountIds = <String>{};
  StreamSubscription<AccountSession>? _subscription;

  void start() {
    _subscription ??= _repository.authSessions.listen(_handleSession);
  }

  Future<AccountResult<void>> begin({required Uri redirectTo}) =>
      _repository.beginGoogleSignIn(redirectTo: redirectTo);

  Future<void> close() async => _subscription?.cancel();

  Future<void> _handleSession(AccountSession session) async {
    final isVerifiedGoogle =
        session.account.isEmailVerified &&
        session.account.authMethods.contains(AccountAuthMethod.google);
    if (!isVerifiedGoogle || !_handledAccountIds.add(session.account.id)) {
      return;
    }
    await _onAuthenticated(session);
  }
}
