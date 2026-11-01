enum AccountFailureCode {
  invalidCredentials,
  emailAlreadyInUse,
  emailUnverified,
  sessionExpired,
  rateLimited,
  networkUnavailable,
  unexpected,
}

class AccountFailure {
  const AccountFailure({required this.code, required this.safeMessageKey});

  const AccountFailure.invalidCredentials()
    : this(
        code: AccountFailureCode.invalidCredentials,
        safeMessageKey: 'account_error_invalid_credentials',
      );

  const AccountFailure.emailAlreadyInUse()
    : this(
        code: AccountFailureCode.emailAlreadyInUse,
        safeMessageKey: 'account_error_email_in_use',
      );

  const AccountFailure.emailUnverified()
    : this(
        code: AccountFailureCode.emailUnverified,
        safeMessageKey: 'account_error_email_unverified',
      );

  const AccountFailure.sessionExpired()
    : this(
        code: AccountFailureCode.sessionExpired,
        safeMessageKey: 'account_error_session_expired',
      );

  const AccountFailure.rateLimited()
    : this(
        code: AccountFailureCode.rateLimited,
        safeMessageKey: 'account_error_rate_limited',
      );

  const AccountFailure.networkUnavailable()
    : this(
        code: AccountFailureCode.networkUnavailable,
        safeMessageKey: 'account_error_network',
      );

  const AccountFailure.unexpected()
    : this(
        code: AccountFailureCode.unexpected,
        safeMessageKey: 'account_error_unexpected',
      );

  final AccountFailureCode code;
  final String safeMessageKey;
}

sealed class AccountResult<T> {
  const AccountResult();
}

final class AccountSuccess<T> extends AccountResult<T> {
  const AccountSuccess(this.value);

  final T value;
}

final class AccountRejected<T> extends AccountResult<T> {
  const AccountRejected(this.failure);

  final AccountFailure failure;
}
