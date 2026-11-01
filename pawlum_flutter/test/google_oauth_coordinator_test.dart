import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pawlum/features/account_access/domain/entities/account_identity.dart';
import 'package:pawlum/features/account_access/domain/entities/account_session.dart';
import 'package:pawlum/features/account_access/domain/failures/account_failure.dart';
import 'package:pawlum/features/account_access/domain/repositories/account_repository.dart';
import 'package:pawlum/features/account_access/domain/use_cases/google_oauth_coordinator.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  test(
    'duplicate Google callbacks bootstrap one verified account once',
    () async {
      final repository = _MockAccountRepository();
      final callbacks = StreamController<AccountSession>.broadcast(sync: true);
      final redirectTo = Uri.parse('pawlum://login-callback');
      var bootstrapCount = 0;
      String? bootstrappedAccountId;
      when(() => repository.authSessions).thenAnswer((_) => callbacks.stream);
      when(
        () => repository.beginGoogleSignIn(redirectTo: redirectTo),
      ).thenAnswer((_) async => const AccountSuccess<void>(null));
      final coordinator = GoogleOAuthCoordinator(
        repository: repository,
        onAuthenticated: (session) async {
          bootstrapCount += 1;
          bootstrappedAccountId = session.account.id;
        },
      );
      final now = DateTime.utc(2026, 10, 31, 9);
      final linkedIdentitySession = AccountSession(
        account: const AccountIdentity(
          id: 'stable-supabase-user-id',
          email: 'linked@example.com',
          isEmailVerified: true,
          authMethods: <AccountAuthMethod>{
            AccountAuthMethod.emailPassword,
            AccountAuthMethod.google,
          },
        ),
        startedAt: now,
        expiresAt: now.add(const Duration(hours: 1)),
      );

      coordinator.start();
      final beginResult = await coordinator.begin(redirectTo: redirectTo);
      callbacks
        ..add(linkedIdentitySession)
        ..add(linkedIdentitySession);
      await Future<void>.delayed(Duration.zero);

      expect(beginResult, isA<AccountSuccess<void>>());
      expect(bootstrapCount, 1);
      expect(bootstrappedAccountId, 'stable-supabase-user-id');
      verify(
        () => repository.beginGoogleSignIn(redirectTo: redirectTo),
      ).called(1);

      await coordinator.close();
      await callbacks.close();
    },
  );

  test('unverified OAuth callback cannot bootstrap a journal', () async {
    final repository = _MockAccountRepository();
    final callbacks = StreamController<AccountSession>.broadcast(sync: true);
    var bootstrapCount = 0;
    when(() => repository.authSessions).thenAnswer((_) => callbacks.stream);
    final coordinator = GoogleOAuthCoordinator(
      repository: repository,
      onAuthenticated: (_) async => bootstrapCount += 1,
    );
    final now = DateTime.utc(2026, 10, 31, 9);

    coordinator.start();
    callbacks.add(
      AccountSession(
        account: const AccountIdentity(
          id: 'unverified-user',
          email: 'unverified@example.com',
          isEmailVerified: false,
          authMethods: <AccountAuthMethod>{AccountAuthMethod.google},
        ),
        startedAt: now,
        expiresAt: now.add(const Duration(hours: 1)),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(bootstrapCount, 0);
    await coordinator.close();
    await callbacks.close();
  });
}
