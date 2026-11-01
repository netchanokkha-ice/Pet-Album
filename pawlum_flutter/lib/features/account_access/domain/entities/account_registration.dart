import 'account_identity.dart';

class AccountRegistration {
  const AccountRegistration({required this.account});

  final AccountIdentity account;

  bool get verificationRequired => !account.isEmailVerified;
}
