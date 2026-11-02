import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';

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
  final Map<String, _SeededVerifiedAccount> _seededAccountsByEmailDigest =
      <String, _SeededVerifiedAccount>{};
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
      passwordDigest: _digest(password),
    );
  }

  void seedVerifiedAccountWithDigests({
    required String id,
    required String emailDigest,
    required String passwordDigest,
  }) {
    _seededAccountsByEmailDigest[emailDigest] = _SeededVerifiedAccount(
      id: id,
      passwordDigest: passwordDigest,
    );
  }

  @override
  Future<AccountResult<AccountRegistration>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    if (_accounts.containsKey(normalizedEmail) ||
        _seededAccountsByEmailDigest.containsKey(_digest(normalizedEmail))) {
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
      passwordDigest: _digest(password),
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
    final normalizedEmail = _normalizeEmail(email);
    final stored =
        _accounts[normalizedEmail] ?? _seededAccount(normalizedEmail);
    if (stored == null || stored.passwordDigest != _digest(password)) {
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

  String _digest(String value) => sha256.convert(utf8.encode(value)).toString();

  _StoredAccount? _seededAccount(String normalizedEmail) {
    final seeded = _seededAccountsByEmailDigest[_digest(normalizedEmail)];
    if (seeded == null) return null;
    return _StoredAccount(
      identity: AccountIdentity(
        id: seeded.id,
        email: normalizedEmail,
        isEmailVerified: true,
        authMethods: const <AccountAuthMethod>{AccountAuthMethod.emailPassword},
      ),
      passwordDigest: seeded.passwordDigest,
    );
  }
}

class _StoredAccount {
  const _StoredAccount({required this.identity, required this.passwordDigest});

  final AccountIdentity identity;
  final String passwordDigest;
}

class _SeededVerifiedAccount {
  const _SeededVerifiedAccount({
    required this.id,
    required this.passwordDigest,
  });

  final String id;
  final String passwordDigest;
}
