import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/features/account_access/data/repositories/in_memory_account_repository.dart';
import 'package:pawlum/features/account_access/domain/entities/account_identity.dart';
import 'package:pawlum/features/account_access/domain/entities/account_session.dart';
import 'package:pawlum/features/app_preferences/data/in_memory_language_preference_store.dart';
import 'package:pawlum/features/app_preferences/domain/app_language.dart';
import 'package:pawlum/features/app_preferences/presentation/app_locale_controller.dart';
import 'package:pawlum/features/app_shell/domain/entities/app_readiness.dart';

import 'helpers/pump_pawlum_app.dart';

void main() {
  tearDown(Get.reset);

  testWidgets(
    'settings supports account, language, recovery, deleted items, and sign-out',
    (tester) async {
      const accountId = 'account-email';
      final now = DateTime.utc(2026, 11, 1, 12);
      final accountRepository = InMemoryAccountRepository(now: () => now)
        ..seedSession(
          AccountSession(
            account: const AccountIdentity(
              id: accountId,
              email: 'keeper@pawlum.test',
              displayName: 'Memory Keeper',
              isEmailVerified: true,
              authMethods: <AccountAuthMethod>{AccountAuthMethod.emailPassword},
            ),
            startedAt: now,
            expiresAt: now.add(const Duration(hours: 1)),
          ),
        );
      final local = InMemoryLocalLanguagePreferenceStore(AppLanguage.english);
      final remote = InMemoryRemoteLanguagePreferenceStore();
      final localeController = await AppLocaleController.load(
        localStore: local,
        remoteStore: remote,
        accountId: accountId,
        deviceLocales: const <Locale>[Locale('en')],
      );

      await tester.pumpPawlumApp(
        readiness: const AppReadiness(
          isAuthenticated: true,
          petCount: 1,
          pendingDraftCount: 0,
        ),
        accountRepository: accountRepository,
        localeController: localeController,
      );
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('keeper@pawlum.test'), findsOneWidget);
      expect(find.text('Memory Keeper'), findsOneWidget);
      expect(find.text('Email and password'), findsOneWidget);
      expect(find.text('Change password'), findsOneWidget);
      expect(find.text('Recently Deleted'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Sharing'), findsNothing);
      expect(find.text('Notifications'), findsNothing);

      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();
      expect(accountRepository.recoveryRequestCount, 1);
      expect(
        find.text('Check your email for a secure password-change link.'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Thai'));
      await tester.tap(find.text('Thai'));
      await tester.pumpAndSettle();
      expect(localeController.language, AppLanguage.thai);
      expect(local.language, AppLanguage.thai);
      expect(remote.values[accountId], AppLanguage.thai);
      expect(find.text('ตั้งค่า'), findsWidgets);

      await tester.ensureVisible(find.text('ออกจากระบบ'));
      await tester.tap(find.text('ออกจากระบบ'));
      await tester.pumpAndSettle();
      expect(find.text('เข้าสู่ระบบ'), findsOneWidget);
      expect(accountRepository.hasStoredSession, isFalse);
    },
  );

  testWidgets('Google-only accounts omit password-change UI', (tester) async {
    final now = DateTime.utc(2026, 11, 1, 13);
    final accountRepository = InMemoryAccountRepository(now: () => now)
      ..seedSession(
        AccountSession(
          account: const AccountIdentity(
            id: 'account-google',
            email: 'google@pawlum.test',
            isEmailVerified: true,
            authMethods: <AccountAuthMethod>{AccountAuthMethod.google},
          ),
          startedAt: now,
          expiresAt: now.add(const Duration(hours: 1)),
        ),
      );
    final localeController = await AppLocaleController.load(
      localStore: InMemoryLocalLanguagePreferenceStore(AppLanguage.english),
      deviceLocales: const <Locale>[Locale('en')],
    );

    await tester.pumpPawlumApp(
      readiness: const AppReadiness(
        isAuthenticated: true,
        petCount: 1,
        pendingDraftCount: 0,
      ),
      accountRepository: accountRepository,
      localeController: localeController,
    );
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Change password'), findsNothing);
    expect(find.text('Recover password'), findsNothing);
  });
}
