import 'account_identity.dart';

class AccountSession {
  const AccountSession({
    required this.account,
    required this.startedAt,
    required this.expiresAt,
  });

  final AccountIdentity account;
  final DateTime startedAt;
  final DateTime expiresAt;

  bool isExpiredAt(DateTime instant) => !expiresAt.isAfter(instant.toUtc());

  bool canAccessJournalAt(DateTime instant) =>
      account.isEmailVerified && !isExpiredAt(instant);
}
