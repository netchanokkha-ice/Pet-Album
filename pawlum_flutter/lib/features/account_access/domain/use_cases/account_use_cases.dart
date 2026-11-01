import '../entities/account_registration.dart';
import '../entities/account_session.dart';
import '../entities/password_recovery_receipt.dart';
import '../failures/account_failure.dart';
import '../repositories/account_repository.dart';

class RegisterWithEmail {
  const RegisterWithEmail(this._repository);

  final AccountRepository _repository;

  Future<AccountResult<AccountRegistration>> call({
    required String email,
    required String password,
  }) => _repository.registerWithEmail(email: email, password: password);
}

class SignInWithEmail {
  const SignInWithEmail(this._repository);

  final AccountRepository _repository;

  Future<AccountResult<AccountSession>> call({
    required String email,
    required String password,
  }) => _repository.signInWithEmail(email: email, password: password);
}

class RestoreAccountSession {
  const RestoreAccountSession(this._repository, {required this.now});

  final AccountRepository _repository;
  final DateTime Function() now;

  Future<AccountResult<AccountSession?>> call() async {
    final result = await _repository.restoreSession();
    return switch (result) {
      AccountSuccess<AccountSession?>(value: final session)
          when session != null && session.isExpiredAt(now()) =>
        const AccountRejected<AccountSession?>(AccountFailure.sessionExpired()),
      _ => result,
    };
  }
}

class ResendVerification {
  const ResendVerification(this._repository);

  final AccountRepository _repository;

  Future<AccountResult<void>> call({required String email}) =>
      _repository.resendVerification(email: email);
}

class RequestPasswordRecovery {
  const RequestPasswordRecovery(this._repository);

  final AccountRepository _repository;

  Future<AccountResult<PasswordRecoveryReceipt>> call({
    required String email,
  }) => _repository.requestPasswordRecovery(email: email);
}

class SignOutAccount {
  const SignOutAccount(this._repository);

  final AccountRepository _repository;

  Future<AccountResult<void>> call() => _repository.signOut();
}
