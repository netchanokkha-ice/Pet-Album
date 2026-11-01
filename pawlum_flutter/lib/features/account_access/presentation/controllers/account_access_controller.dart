import 'dart:async';

import 'package:get/get.dart';

import '../../domain/entities/account_registration.dart';
import '../../domain/entities/account_session.dart';
import '../../domain/entities/password_recovery_receipt.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/use_cases/google_oauth_coordinator.dart';

enum AccountAccessStep {
  signIn,
  signUp,
  verificationPending,
  forgotPassword,
  recoveryResult,
}

class AccountAccessController extends GetxController {
  AccountAccessController(
    this._repository, {
    required this.googleOAuthEnabled,
    required this.oauthRedirectUri,
    required this.onAuthenticated,
  }) : _googleOAuth = GoogleOAuthCoordinator(
         repository: _repository,
         onAuthenticated: onAuthenticated,
       );

  final AccountRepository _repository;
  final bool googleOAuthEnabled;
  final Uri? oauthRedirectUri;
  final Future<void> Function(AccountSession session) onAuthenticated;
  final GoogleOAuthCoordinator _googleOAuth;

  bool get googleOAuthAvailable =>
      googleOAuthEnabled && oauthRedirectUri?.hasScheme == true;

  final step = AccountAccessStep.signIn.obs;
  final isLoading = false.obs;
  final errorKey = RxnString();
  final noticeKey = RxnString();
  final pendingEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (googleOAuthAvailable) _googleOAuth.start();
  }

  @override
  void onClose() {
    unawaited(_googleOAuth.close());
    super.onClose();
  }

  void showSignIn() => _moveTo(AccountAccessStep.signIn);
  void showSignUp() => _moveTo(AccountAccessStep.signUp);
  void showForgotPassword() => _moveTo(AccountAccessStep.forgotPassword);

  Future<void> signUp({required String email, required String password}) async {
    await _run<AccountRegistration>(
      () => _repository.registerWithEmail(email: email, password: password),
      onSuccess: (registration) {
        pendingEmail.value = registration.account.email;
        step.value = AccountAccessStep.verificationPending;
      },
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    AccountSession? authenticated;
    await _run<AccountSession>(
      () => _repository.signInWithEmail(email: email, password: password),
      onSuccess: (session) {
        authenticated = session;
        noticeKey.value = 'account_success_signed_in';
      },
      onFailure: (failure) {
        if (failure.code == AccountFailureCode.emailUnverified) {
          pendingEmail.value = email.trim();
          step.value = AccountAccessStep.verificationPending;
          return true;
        }
        return false;
      },
    );
    final session = authenticated;
    if (session != null) await onAuthenticated(session);
  }

  Future<void> resendVerification() async {
    await _run<void>(
      () => _repository.resendVerification(email: pendingEmail.value),
      onSuccess: (_) => noticeKey.value = 'account_success_verification_sent',
    );
  }

  Future<void> requestRecovery({required String email}) async {
    await _run<PasswordRecoveryReceipt>(
      () => _repository.requestPasswordRecovery(email: email),
      onSuccess: (_) {
        pendingEmail.value = email.trim();
        step.value = AccountAccessStep.recoveryResult;
      },
    );
  }

  Future<void> beginGoogleSignIn() async {
    final redirectUri = oauthRedirectUri;
    if (!googleOAuthAvailable || redirectUri == null) return;
    isLoading.value = true;
    errorKey.value = null;
    noticeKey.value = null;
    final result = await _googleOAuth.begin(redirectTo: redirectUri);
    if (result case AccountRejected<void>(failure: final failure)) {
      errorKey.value = failure.safeMessageKey;
    }
    isLoading.value = false;
  }

  void _moveTo(AccountAccessStep target) {
    errorKey.value = null;
    noticeKey.value = null;
    step.value = target;
  }

  Future<void> _run<T>(
    Future<AccountResult<T>> Function() operation, {
    required void Function(T value) onSuccess,
    bool Function(AccountFailure failure)? onFailure,
  }) async {
    isLoading.value = true;
    errorKey.value = null;
    noticeKey.value = null;
    final result = await operation();
    switch (result) {
      case AccountSuccess<T>(value: final value):
        onSuccess(value);
      case AccountRejected<T>(failure: final failure):
        if (onFailure?.call(failure) != true) {
          errorKey.value = failure.safeMessageKey;
        }
    }
    isLoading.value = false;
  }
}
