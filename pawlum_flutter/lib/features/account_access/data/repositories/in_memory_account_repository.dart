import 'dart:async';

import '../../domain/entities/account_identity.dart';
import '../../domain/entities/account_registration.dart';
import '../../domain/entities/account_session.dart';
import '../../domain/entities/password_recovery_receipt.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';

class InMemoryAccountRepository implements AccountRepository {
  InMemoryAccountRepository({
    required this.now,
    this.sessionDuration = const Duration(hours: 1),
  });

  final DateTime Function() now;
  final Duration sessionDuration;
  final Map<String, _StoredAccount> _accounts = <String, _StoredAccount>{};
  final StreamController<AccountSession> _authSessions =
      StreamController<AccountSession>.broadcast(sync: true);

  AccountSession? _storedSession;
  int _nextAccountNumber = 1;
  int recoveryRequestCount = 0;
  int verificationResendCount = 0;

  bool get hasStoredSession => _storedSession != null;

  @override
  Stream<AccountSession> get authSessions => _authSessions.stream;

  Uri? lastGoogleRedirect;

  void emitAuthSession(AccountSession session) => _authSessions.add(session);

  void seedSession(AccountSession session) {
    _storedSession = session;
  }

  void seedAccount({
    required AccountIdentity account,
    required String password,
  }) {
    _accounts[_normalizeEmail(account.email)] = _StoredAccount(
      identity: account,
      password: password,
    );
  }

  @override
  Future<AccountResult<AccountRegistration>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    if (_accounts.containsKey(normalizedEmail)) {
      return const AccountRejected<AccountRegistration>(
        AccountFailure.emailAlreadyInUse(),
      );
    }

    final identity = AccountIdentity(
      id: 'account-${_nextAccountNumber++}',
      email: normalizedEmail,
      isEmailVerified: false,
      authMethods: const <AccountAuthMethod>{AccountAuthMethod.emailPassword},
    );
    _accounts[normalizedEmail] = _StoredAccount(
      identity: identity,
      password: password,
    );
    return AccountSuccess<AccountRegistration>(
      AccountRegistration(account: identity),
    );
  }

  @override
  Future<AccountResult<AccountSession>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final stored = _accounts[_normalizeEmail(email)];
    if (stored == null || stored.password != password) {
      return const AccountRejected<AccountSession>(
        AccountFailure.invalidCredentials(),
      );
    }

    if (!stored.identity.isEmailVerified) {
      return const AccountRejected<AccountSession>(
        AccountFailure.emailUnverified(),
      );
    }

    final session = _newSession(stored.identity);
    _storedSession = session;
    return AccountSuccess<AccountSession>(session);
  }

  @override
  Future<AccountResult<AccountSession?>> restoreSession() async =>
      AccountSuccess<AccountSession?>(_storedSession);

  @override
  Future<AccountResult<void>> resendVerification({
    required String email,
  }) async {
    final account = _accounts[_normalizeEmail(email)];
    if (account == null) {
      return const AccountRejected<void>(AccountFailure.invalidCredentials());
    }
    verificationResendCount += 1;
    return const AccountSuccess<void>(null);
  }

  @override
  Future<AccountResult<PasswordRecoveryReceipt>> requestPasswordRecovery({
    required String email,
  }) async {
    _normalizeEmail(email);
    recoveryRequestCount += 1;
    return AccountSuccess<PasswordRecoveryReceipt>(
      PasswordRecoveryReceipt(acceptedAt: now().toUtc()),
    );
  }

  @override
  Future<AccountResult<void>> signOut() async {
    _storedSession = null;
    return const AccountSuccess<void>(null);
  }

  @override
  Future<AccountResult<void>> beginGoogleSignIn({
    required Uri redirectTo,
  }) async {
    lastGoogleRedirect = redirectTo;
    return const AccountSuccess<void>(null);
  }

  AccountSession _newSession(AccountIdentity identity) {
    final startedAt = now().toUtc();
    return AccountSession(
      account: identity,
      startedAt: startedAt,
      expiresAt: startedAt.add(sessionDuration),
    );
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
}

class _StoredAccount {
  const _StoredAccount({required this.identity, required this.password});

  final AccountIdentity identity;
  final String password;
}
