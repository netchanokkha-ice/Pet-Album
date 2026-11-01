import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/features/account_access/data/repositories/in_memory_account_repository.dart';
import 'package:pawlum/features/account_access/domain/entities/account_identity.dart';
import 'package:pawlum/features/account_access/domain/entities/account_session.dart';
import 'package:pawlum/features/app_shell/domain/entities/app_readiness.dart';

import 'helpers/pump_pawlum_app.dart';

void main() {
  setUpAll(_loadGoldenFonts);
  tearDown(Get.reset);

  const ready = AppReadiness(
    isAuthenticated: true,
    petCount: 1,
    pendingDraftCount: 1,
  );

  testWidgets('route guard selects the signed-out destination', (tester) async {
    await tester.pumpPawlumApp();
    expect(find.text('Welcome to Pawlum'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('route guard selects the onboarding destination', (tester) async {
    await tester.pumpPawlumApp(
      readiness: const AppReadiness(
        isAuthenticated: true,
        petCount: 0,
        pendingDraftCount: 0,
      ),
    );
    expect(find.text('Add your first pet'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('expired session routes to sign-in and keeps draft protected', (
    tester,
  ) async {
    final now = DateTime.now().toUtc();
    final accounts = InMemoryAccountRepository(now: () => now)
      ..seedSession(
        AccountSession(
          account: const AccountIdentity(
            id: 'expired-user',
            email: 'expired@example.com',
            isEmailVerified: true,
            authMethods: <AccountAuthMethod>{AccountAuthMethod.emailPassword},
          ),
          startedAt: now.subtract(const Duration(hours: 2)),
          expiresAt: now.subtract(const Duration(hours: 1)),
        ),
      );

    await tester.pumpPawlumApp(
      readiness: const AppReadiness(
        isAuthenticated: true,
        petCount: 1,
        pendingDraftCount: 1,
      ),
      accountRepository: accounts,
    );

    expect(find.text('Welcome to Pawlum'), findsOneWidget);
    expect(
      find.text('Your local draft is safe. Sign in to continue saving it.'),
      findsOneWidget,
    );
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('authenticated navigation reaches every shell destination', (
    tester,
  ) async {
    await tester.pumpPawlumApp(readiness: ready);
    expect(find.text('Home'), findsWidgets);

    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();
    expect(find.text('Choose media'), findsOneWidget);
    expect(find.bySemanticsLabel('Step 1 of 4, Choose media'), findsOneWidget);

    await tester.tap(find.text('Timeline').last);
    await tester.pumpAndSettle();
    expect(find.text('Timeline'), findsWidgets);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);

    await tester.ensureVisible(find.text('Recently Deleted'));
    await tester.tap(find.text('Recently Deleted'));
    await tester.pumpAndSettle();
    expect(find.text('Recently Deleted'), findsOneWidget);
  });

  testWidgets('authenticated phone shell matches its golden', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpPawlumApp(readiness: ready);

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/app_shell_home_phone.png'),
    );
  });

  testWidgets('loading pattern is announced while readiness loads', (
    tester,
  ) async {
    await tester.pumpPawlumApp(
      readiness: ready,
      loadDelay: const Duration(seconds: 1),
      settle: false,
    );
    await tester.pump();
    expect(find.bySemanticsLabel('Loading Pawlum'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('error pattern offers a retry action', (tester) async {
    await tester.pumpPawlumApp(loadError: StateError('offline'));
    expect(find.text('Journal unavailable'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('active destination survives an orientation change', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpPawlumApp(readiness: ready);
    await tester.tap(find.text('Timeline').last);
    await tester.pumpAndSettle();
    expect(find.text('Timeline'), findsWidgets);

    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();
    expect(find.text('Timeline'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
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
