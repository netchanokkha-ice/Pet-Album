import '../entities/account_registration.dart';
import '../entities/account_session.dart';
import '../entities/password_recovery_receipt.dart';
import '../failures/account_failure.dart';

abstract interface class AccountRepository {
  Stream<AccountSession> get authSessions;

  Future<AccountResult<AccountRegistration>> registerWithEmail({
    required String email,
    required String password,
  });

  Future<AccountResult<AccountSession>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AccountResult<AccountSession?>> restoreSession();

  Future<AccountResult<void>> resendVerification({required String email});

  Future<AccountResult<PasswordRecoveryReceipt>> requestPasswordRecovery({
    required String email,
  });

  Future<AccountResult<void>> signOut();

  Future<AccountResult<void>> beginGoogleSignIn({required Uri redirectTo});
}
