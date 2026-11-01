import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pawlum/features/account_access/data/data_sources/supabase_auth_data_source.dart';
import 'package:pawlum/features/account_access/data/repositories/supabase_account_repository.dart';
import 'package:pawlum/features/account_access/domain/entities/account_identity.dart';
import 'package:pawlum/features/account_access/domain/entities/account_registration.dart';
import 'package:pawlum/features/account_access/domain/entities/account_session.dart';
import 'package:pawlum/features/account_access/domain/entities/password_recovery_receipt.dart';
import 'package:pawlum/features/account_access/domain/failures/account_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseAuthDataSource extends Mock
    implements SupabaseAuthDataSource {}

void main() {
  late DateTime now;
  late _MockSupabaseAuthDataSource dataSource;
  late SupabaseAccountRepository repository;
  late SupabaseAuthUserSnapshot verifiedUser;
  late SupabaseAuthSessionSnapshot activeSession;

  setUp(() {
    now = DateTime.utc(2026, 10, 31, 9);
    dataSource = _MockSupabaseAuthDataSource();
    repository = SupabaseAccountRepository(dataSource, now: () => now);
    verifiedUser = const SupabaseAuthUserSnapshot(
      id: 'user-1',
      email: 'mali@example.com',
      displayName: 'Mali',
      emailVerified: true,
      providers: <String>{'email', 'google'},
    );
    activeSession = SupabaseAuthSessionSnapshot(
      user: verifiedUser,
      startedAt: now,
      expiresAt: now.add(const Duration(hours: 1)),
    );
  });

  test('maps installed Supabase SDK user and session objects', () {
    final sdkUser = User.fromJson(<String, dynamic>{
      'id': 'sdk-user',
      'email': 'sdk@example.com',
      'email_confirmed_at': '2026-10-30T00:00:00Z',
      'user_metadata': <String, dynamic>{'display_name': 'SDK Mali'},
      'identities': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'identity-1',
          'user_id': 'sdk-user',
          'identity_id': 'identity-1',
          'provider': 'google',
        },
      ],
    })!;
    final sdkSession = Session(
      accessToken: 'fixture-token-without-jwt-payload',
      expiresIn: 3600,
      refreshToken: 'fixture-refresh-token',
      tokenType: 'bearer',
      user: sdkUser,
    );

    final mapped = SupabaseAuthSnapshotMapper(
      now: () => now,
    ).mapSession(sdkSession);

    expect(mapped.user.id, 'sdk-user');
    expect(mapped.user.displayName, 'SDK Mali');
    expect(mapped.user.emailVerified, isTrue);
    expect(mapped.user.providers, <String>{'google'});
    expect(mapped.startedAt, now);
    expect(mapped.expiresAt, now.add(const Duration(hours: 1)));
  });

  test('maps signup without an SDK session to pending registration', () async {
    when(
      () => dataSource.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const SupabaseSignUpSnapshot(
        user: SupabaseAuthUserSnapshot(
          id: 'pending-user',
          email: 'pending@example.com',
          emailVerified: false,
          providers: <String>{'email'},
        ),
      ),
    );

    final result = await repository.registerWithEmail(
      email: ' pending@example.com ',
      password: 'safe-password',
    );

    final registration = (result as AccountSuccess<AccountRegistration>).value;
    expect(registration.verificationRequired, isTrue);
    expect(registration.account.email, 'pending@example.com');
    verify(
      () => dataSource.signUp(
        email: 'pending@example.com',
        password: 'safe-password',
      ),
    ).called(1);
  });

  test('maps verified SDK session and provider identities', () async {
    when(
      () => dataSource.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => activeSession);
    when(
      () => dataSource.restoreSession(),
    ).thenAnswer((_) async => activeSession);

    final signedIn = await repository.signInWithEmail(
      email: 'mali@example.com',
      password: 'safe-password',
    );
    final session = (signedIn as AccountSuccess<AccountSession>).value;
    expect(session.account.displayName, 'Mali');
    expect(session.account.authMethods, <AccountAuthMethod>{
      AccountAuthMethod.emailPassword,
      AccountAuthMethod.google,
    });
    expect(session.canAccessJournalAt(now), isTrue);

    final restored = await repository.restoreSession();
    expect(
      (restored as AccountSuccess<AccountSession?>).value?.account.id,
      'user-1',
    );
  });

  test('resend and sign-out delegate to the SDK data source', () async {
    when(
      () => dataSource.resendVerification(email: any(named: 'email')),
    ).thenAnswer((_) async {});
    when(() => dataSource.signOut()).thenAnswer((_) async {});

    final resent = await repository.resendVerification(
      email: ' mali@example.com ',
    );
    final signedOut = await repository.signOut();

    expect(resent, isA<AccountSuccess<void>>());
    expect(signedOut, isA<AccountSuccess<void>>());
    verify(
      () => dataSource.resendVerification(email: 'mali@example.com'),
    ).called(1);
    verify(() => dataSource.signOut()).called(1);
  });

  test(
    'maps OAuth auth-state callbacks and delegates configured redirect',
    () async {
      final redirectTo = Uri.parse('pawlum://login-callback');
      when(() => dataSource.authSessions).thenAnswer(
        (_) => Stream<SupabaseAuthSessionSnapshot>.value(activeSession),
      );
      when(
        () => dataSource.beginGoogleSignIn(redirectTo: redirectTo),
      ).thenAnswer((_) async {});

      final callbackSession = await repository.authSessions.first;
      final beginResult = await repository.beginGoogleSignIn(
        redirectTo: redirectTo,
      );

      expect(callbackSession.account.id, 'user-1');
      expect(
        callbackSession.account.authMethods,
        contains(AccountAuthMethod.google),
      );
      expect(beginResult, isA<AccountSuccess<void>>());
      verify(
        () => dataSource.beginGoogleSignIn(redirectTo: redirectTo),
      ).called(1);
    },
  );

  test('password recovery never discloses account existence', () async {
    when(
      () => dataSource.requestPasswordRecovery(email: 'known@example.com'),
    ).thenAnswer((_) async {});
    when(
      () => dataSource.requestPasswordRecovery(email: 'unknown@example.com'),
    ).thenThrow(
      const AuthException(
        'User does not exist in auth.users.',
        code: 'user_not_found',
      ),
    );

    final known = await repository.requestPasswordRecovery(
      email: 'known@example.com',
    );
    final unknown = await repository.requestPasswordRecovery(
      email: 'unknown@example.com',
    );

    expect(known, isA<AccountSuccess<PasswordRecoveryReceipt>>());
    expect(unknown, isA<AccountSuccess<PasswordRecoveryReceipt>>());
    expect(
      (known as AccountSuccess<PasswordRecoveryReceipt>).value.acceptedAt,
      (unknown as AccountSuccess<PasswordRecoveryReceipt>).value.acceptedAt,
    );
  });

  test(
    'maps SDK errors to safe domain failures without raw messages',
    () async {
      const secretSdkMessage =
          'Password rejected for internal record tenant-42@example.com';
      when(
        () => dataSource.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const AuthException(
          secretSdkMessage,
          statusCode: '400',
          code: 'invalid_credentials',
        ),
      );

      final result = await repository.signInWithEmail(
        email: 'mali@example.com',
        password: 'wrong-password',
      );

      final failure = (result as AccountRejected<AccountSession>).failure;
      expect(failure.code, AccountFailureCode.invalidCredentials);
      expect(failure.safeMessageKey, isNot(contains(secretSdkMessage)));
      expect(failure.safeMessageKey, 'account_error_invalid_credentials');
    },
  );
}
