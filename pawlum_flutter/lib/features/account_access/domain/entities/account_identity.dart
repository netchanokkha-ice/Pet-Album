enum AccountAuthMethod { emailPassword, google }

class AccountIdentity {
  const AccountIdentity({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    required this.authMethods,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;
  final bool isEmailVerified;
  final Set<AccountAuthMethod> authMethods;
}
