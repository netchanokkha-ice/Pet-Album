import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pawlum/core/config/app_config.dart';
import 'package:pawlum/features/account_access/domain/entities/account_identity.dart';
import 'package:pawlum/features/account_access/domain/entities/account_registration.dart';
import 'package:pawlum/features/account_access/domain/entities/account_session.dart';
import 'package:pawlum/features/account_access/domain/entities/password_recovery_receipt.dart';
import 'package:pawlum/features/account_access/domain/failures/account_failure.dart';
import 'package:pawlum/features/account_access/domain/repositories/account_repository.dart';

import 'helpers/pump_pawlum_app.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  late _MockAccountRepository repository;

  setUpAll(_loadGoldenFonts);
  setUp(() {
    repository = _MockAccountRepository();
    when(
      () => repository.restoreSession(),
    ).thenAnswer((_) async => const AccountSuccess<AccountSession?>(null));
  });
  tearDown(Get.reset);

  testWidgets('sign-in form validates required credentials', (tester) async {
    await _openAccountAccess(tester, repository);

    await tester.tap(find.text('Sign in').last);
    await tester.pump();

    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    verifyNever(
      () => repository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('password visibility control reveals and hides the password', (
    tester,
  ) async {
    await _openAccountAccess(tester, repository);

    EditableText passwordInput() => tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('account-password-field')),
        matching: find.byType(EditableText),
      ),
    );

    expect(passwordInput().obscureText, isTrue);
    expect(find.byTooltip('Show password'), findsOneWidget);

    await tester.tap(find.byKey(const Key('account-password-visibility')));
    await tester.pump();

    expect(passwordInput().obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);

    await tester.tap(find.byKey(const Key('account-password-visibility')));
    await tester.pump();

    expect(passwordInput().obscureText, isTrue);
  });

  testWidgets('phone sign-in screen matches its golden', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await _openAccountAccess(tester, repository);

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/account_sign_in_phone.png'),
    );
  });

  testWidgets('configured Google OAuth entry delegates its redirect', (
    tester,
  ) async {
    final redirectTo = Uri.parse('pawlum://login-callback');
    when(
      () => repository.authSessions,
    ).thenAnswer((_) => const Stream<AccountSession>.empty());
    when(
      () => repository.beginGoogleSignIn(redirectTo: redirectTo),
    ).thenAnswer((_) async => const AccountSuccess<void>(null));
    const config = AppConfig(
      environment: AppEnvironment.development,
      supabaseUrl: 'https://projowodlrydgzexcald.supabase.co',
      supabasePublishableKey: 'publishable-test-key',
      useFakeRepositories: false,
      googleOAuthEnabled: true,
      oauthRedirectUrl: 'pawlum://login-callback',
    );

    await tester.pumpPawlumApp(
      config: config,
      accountRepository: repository,
      locale: const Locale('en'),
    );
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google'), findsOneWidget);
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    verify(
      () => repository.beginGoogleSignIn(redirectTo: redirectTo),
    ).called(1);
  });

  testWidgets('signup reaches verification pending and supports resend', (
    tester,
  ) async {
    when(
      () => repository.registerWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const AccountSuccess<AccountRegistration>(
        AccountRegistration(
          account: AccountIdentity(
            id: 'pending-user',
            email: 'pending@example.com',
            isEmailVerified: false,
            authMethods: <AccountAuthMethod>{AccountAuthMethod.emailPassword},
          ),
        ),
      ),
    );
    when(
      () => repository.resendVerification(email: any(named: 'email')),
    ).thenAnswer((_) async => const AccountSuccess<void>(null));
    await _openAccountAccess(tester, repository);

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('account-email-field')),
      'pending@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('account-password-field')),
      'safe-password',
    );
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Check your email'), findsOneWidget);
    expect(find.textContaining('pending@example.com'), findsOneWidget);

    await tester.tap(find.text('Send the link again'));
    await tester.pumpAndSettle();
    expect(find.text('A new verification link is on the way.'), findsOneWidget);
  });

  testWidgets('sign-in exposes loading then returns to the journal', (
    tester,
  ) async {
    final completer = Completer<AccountResult<AccountSession>>();
    when(
      () => repository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => completer.future);
    await _openAccountAccess(tester, repository);

    await _enterSignInCredentials(tester);
    await tester.tap(find.text('Sign in').last);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final now = DateTime.now().toUtc();
    final session = AccountSession(
      account: const AccountIdentity(
        id: 'verified-user',
        email: 'mali@example.com',
        isEmailVerified: true,
        authMethods: <AccountAuthMethod>{AccountAuthMethod.emailPassword},
      ),
      startedAt: now,
      expiresAt: now.add(const Duration(hours: 1)),
    );
    when(
      () => repository.restoreSession(),
    ).thenAnswer((_) async => AccountSuccess<AccountSession?>(session));
    completer.complete(AccountSuccess<AccountSession>(session));
    await tester.pumpAndSettle();

    expect(find.text('Add your first pet'), findsOneWidget);
    expect(find.text('Signed in securely.'), findsNothing);
  });

  testWidgets('sign-in shows only a non-sensitive mapped error', (
    tester,
  ) async {
    when(
      () => repository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const AccountRejected<AccountSession>(
        AccountFailure.invalidCredentials(),
      ),
    );
    await _openAccountAccess(tester, repository);

    await _enterSignInCredentials(tester);
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(find.textContaining('tenant-42'), findsNothing);
  });

  testWidgets('Thai forgot-password flow reaches neutral recovery result', (
    tester,
  ) async {
    when(
      () => repository.requestPasswordRecovery(email: any(named: 'email')),
    ).thenAnswer(
      (_) async => AccountSuccess<PasswordRecoveryReceipt>(
        PasswordRecoveryReceipt(acceptedAt: DateTime.utc(2026, 10, 31, 9)),
      ),
    );
    await _openAccountAccess(tester, repository, locale: const Locale('th'));

    await tester.tap(find.text('ลืมรหัสผ่าน?'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('recovery-email-field')),
      'ใครก็ได้@example.com',
    );
    await tester.tap(find.text('ส่งอีเมลกู้คืน'));
    await tester.pumpAndSettle();

    expect(find.text('เช็กกล่องข้อความ'), findsOneWidget);
    expect(
      find.text('หากอีเมลนี้มีบัญชีอยู่ ขั้นตอนกู้คืนกำลังเดินทางไปหาแล้ว'),
      findsOneWidget,
    );
  });
}

Future<void> _openAccountAccess(
  WidgetTester tester,
  AccountRepository repository, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpPawlumApp(accountRepository: repository, locale: locale);
  await tester.tap(
    find.text(locale.languageCode == 'th' ? 'เข้าสู่ระบบ' : 'Sign in'),
  );
  await tester.pumpAndSettle();
}

Future<void> _enterSignInCredentials(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('account-email-field')),
    'mali@example.com',
  );
  await tester.enterText(
    find.byKey(const Key('account-password-field')),
    'safe-password',
  );
}

Future<void> _loadGoldenFonts() async {
  final fonts = <(String, String)>[
    ('PawlumJua', 'assets/fonts/Jua-Regular.ttf'),
    ('PawlumItim', 'assets/fonts/Itim-Regular.ttf'),
    ('PawlumCaveat', 'assets/fonts/Caveat-Variable.ttf'),
    ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
  ];

  for (final (family, assetPath) in fonts) {
    final loader = FontLoader(family)..addFont(rootBundle.load(assetPath));
    await loader.load();
  }
}
