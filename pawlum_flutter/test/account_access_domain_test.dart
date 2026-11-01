import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/features/account_access/data/repositories/in_memory_account_repository.dart';
import 'package:pawlum/features/account_access/domain/entities/account_identity.dart';
import 'package:pawlum/features/account_access/domain/entities/account_registration.dart';
import 'package:pawlum/features/account_access/domain/entities/account_session.dart';
import 'package:pawlum/features/account_access/domain/entities/password_recovery_receipt.dart';
import 'package:pawlum/features/account_access/domain/failures/account_failure.dart';
import 'package:pawlum/features/account_access/domain/use_cases/account_use_cases.dart';

void main() {
  late DateTime now;
  late InMemoryAccountRepository repository;

  setUp(() {
    now = DateTime.utc(2026, 10, 31, 9);
    repository = InMemoryAccountRepository(now: () => now);
  });

  test(
    'registration creates an unverified account outside the journal',
    () async {
      final result = await RegisterWithEmail(repository)(
        email: ' New@Example.com ',
        password: 'safe-password',
      );

      expect(result, isA<AccountSuccess<AccountRegistration>>());
      final registration =
          (result as AccountSuccess<AccountRegistration>).value;
      expect(registration.account.email, 'new@example.com');
      expect(registration.verificationRequired, isTrue);

      final signedIn = await SignInWithEmail(repository)(
        email: 'new@example.com',
        password: 'safe-password',
      );
      expect(signedIn, isA<AccountRejected<AccountSession>>());
      expect(
        (signedIn as AccountRejected<AccountSession>).failure.code,
        AccountFailureCode.emailUnverified,
      );

      final resent = await ResendVerification(repository)(
        email: 'new@example.com',
      );
      expect(resent, isA<AccountSuccess<void>>());
      expect(repository.verificationResendCount, 1);
    },
  );

  test('verified account signs in and restores an active session', () async {
    repository.seedAccount(
      account: const AccountIdentity(
        id: 'verified-user',
        email: 'verified@example.com',
        displayName: 'Mali',
        isEmailVerified: true,
        authMethods: <AccountAuthMethod>{AccountAuthMethod.emailPassword},
      ),
      password: 'correct-password',
    );

    final signedIn = await SignInWithEmail(repository)(
      email: 'verified@example.com',
      password: 'correct-password',
    );
    final session = (signedIn as AccountSuccess<AccountSession>).value;
    expect(session.canAccessJournalAt(now), isTrue);

    final restored = await RestoreAccountSession(repository, now: () => now)();
    expect(restored, isA<AccountSuccess<AccountSession?>>());
    expect(
      (restored as AccountSuccess<AccountSession?>).value?.account.id,
      'verified-user',
    );
  });

  test('expired stored session becomes a typed recoverable failure', () async {
    repository.seedAccount(
      account: const AccountIdentity(
        id: 'expired-user',
        email: 'expired@example.com',
        isEmailVerified: true,
        authMethods: <AccountAuthMethod>{AccountAuthMethod.emailPassword},
      ),
      password: 'correct-password',
    );
    await SignInWithEmail(repository)(
      email: 'expired@example.com',
      password: 'correct-password',
    );
    now = now.add(const Duration(hours: 2));

    final result = await RestoreAccountSession(repository, now: () => now)();

    expect(result, isA<AccountRejected<AccountSession?>>());
    expect(
      (result as AccountRejected<AccountSession?>).failure.code,
      AccountFailureCode.sessionExpired,
    );
    expect(repository.hasStoredSession, isTrue);
  });

  test(
    'recovery accepts known and unknown emails without disclosure',
    () async {
      repository.seedAccount(
        account: const AccountIdentity(
          id: 'known-user',
          email: 'known@example.com',
          isEmailVerified: true,
          authMethods: <AccountAuthMethod>{AccountAuthMethod.emailPassword},
        ),
        password: 'correct-password',
      );
      final recover = RequestPasswordRecovery(repository);

      final known = await recover(email: 'known@example.com');
      final unknown = await recover(email: 'unknown@example.com');

      expect(known, isA<AccountSuccess<PasswordRecoveryReceipt>>());
      expect(unknown, isA<AccountSuccess<PasswordRecoveryReceipt>>());
      expect(
        (known as AccountSuccess<PasswordRecoveryReceipt>).value.acceptedAt,
        (unknown as AccountSuccess<PasswordRecoveryReceipt>).value.acceptedAt,
      );
      expect(repository.recoveryRequestCount, 2);
    },
  );
}
