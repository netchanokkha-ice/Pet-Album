import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/account_identity.dart';
import '../../domain/entities/account_registration.dart';
import '../../domain/entities/account_session.dart';
import '../../domain/entities/password_recovery_receipt.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';
import '../data_sources/supabase_auth_data_source.dart';

class SupabaseAccountRepository implements AccountRepository {
  const SupabaseAccountRepository(this._dataSource, {required this.now});

  final SupabaseAuthDataSource _dataSource;
  final DateTime Function() now;

  @override
  Stream<AccountSession> get authSessions =>
      _dataSource.authSessions.map(_mapSession);

  @override
  Future<AccountResult<AccountRegistration>> registerWithEmail({
    required String email,
    required String password,
  }) => _guard(() async {
    final response = await _dataSource.signUp(
      email: email.trim(),
      password: password,
    );
    return AccountRegistration(account: _mapIdentity(response.user));
  });

  @override
  Future<AccountResult<AccountSession>> signInWithEmail({
    required String email,
    required String password,
  }) => _guard(() async {
    final response = await _dataSource.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    if (!response.user.emailVerified) {
      throw const AuthException(
        'Email is not verified.',
        code: 'email_not_confirmed',
      );
    }
    return _mapSession(response);
  });

  @override
  Future<AccountResult<AccountSession?>> restoreSession() => _guard(() async {
    final session = await _dataSource.restoreSession();
    return session == null ? null : _mapSession(session);
  });

  @override
  Future<AccountResult<void>> resendVerification({required String email}) =>
      _guard(() async {
        await _dataSource.resendVerification(email: email.trim());
      });

  @override
  Future<AccountResult<PasswordRecoveryReceipt>> requestPasswordRecovery({
    required String email,
  }) async {
    try {
      await _dataSource.requestPasswordRecovery(email: email.trim());
    } on AuthException catch (error) {
      if (error.code != 'user_not_found') {
        return AccountRejected<PasswordRecoveryReceipt>(_mapFailure(error));
      }
    } on TimeoutException {
      return const AccountRejected<PasswordRecoveryReceipt>(
        AccountFailure.networkUnavailable(),
      );
    } on SocketException {
      return const AccountRejected<PasswordRecoveryReceipt>(
        AccountFailure.networkUnavailable(),
      );
    } on Object {
      return const AccountRejected<PasswordRecoveryReceipt>(
        AccountFailure.unexpected(),
      );
    }
    return AccountSuccess<PasswordRecoveryReceipt>(
      PasswordRecoveryReceipt(acceptedAt: now().toUtc()),
    );
  }

  @override
  Future<AccountResult<void>> signOut() => _guard(() => _dataSource.signOut());

  @override
  Future<AccountResult<void>> beginGoogleSignIn({required Uri redirectTo}) =>
      _guard(() => _dataSource.beginGoogleSignIn(redirectTo: redirectTo));

  Future<AccountResult<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return AccountSuccess<T>(await operation());
    } on AuthException catch (error) {
      return AccountRejected<T>(_mapFailure(error));
    } on TimeoutException {
      return AccountRejected<T>(const AccountFailure.networkUnavailable());
    } on SocketException {
      return AccountRejected<T>(const AccountFailure.networkUnavailable());
    } on Object {
      return AccountRejected<T>(const AccountFailure.unexpected());
    }
  }

  AccountSession _mapSession(SupabaseAuthSessionSnapshot session) =>
      AccountSession(
        account: _mapIdentity(session.user),
        startedAt: session.startedAt,
        expiresAt: session.expiresAt,
      );

  AccountIdentity _mapIdentity(SupabaseAuthUserSnapshot user) =>
      AccountIdentity(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        isEmailVerified: user.emailVerified,
        authMethods: user.providers.map(_mapProvider).toSet(),
      );

  AccountAuthMethod _mapProvider(String provider) => switch (provider) {
    'google' => AccountAuthMethod.google,
    _ => AccountAuthMethod.emailPassword,
  };

  AccountFailure _mapFailure(AuthException error) => switch (error.code) {
    'invalid_credentials' => const AccountFailure.invalidCredentials(),
    'email_not_confirmed' => const AccountFailure.emailUnverified(),
    'email_exists' ||
    'user_already_exists' => const AccountFailure.emailAlreadyInUse(),
    'over_email_send_rate_limit' ||
    'over_request_rate_limit' => const AccountFailure.rateLimited(),
    _ when error.statusCode == '429' => const AccountFailure.rateLimited(),
    _ => const AccountFailure.unexpected(),
  };
}
