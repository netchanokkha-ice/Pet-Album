import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/app/bootstrap/app_bootstrap.dart';
import 'package:pawlum/core/config/app_config.dart';

import 'helpers/pump_pawlum_app.dart';

void main() {
  tearDown(Get.reset);

  test('test configuration does not require Supabase credentials', () {
    final config = AppConfig.test();

    expect(config.hasSupabaseCredentials, isFalse);
    expect(config.useFakeRepositories, isTrue);
  });

  testWidgets('fake bootstrap launches the signed-out Pawlum shell', (
    tester,
  ) async {
    await tester.pumpPawlumApp();

    expect(find.text('Welcome to Pawlum'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('demo bootstrap signs a verified account into onboarding', (
    tester,
  ) async {
    const email = 'demo@example.com';
    const password = 'demo-password';
    String digest(String value) =>
        sha256.convert(utf8.encode(value)).toString();
    final bootstrap = AppBootstrap.demo(
      config: AppConfig.test(),
      accountEmailDigest: digest(email),
      accountPasswordDigest: digest(password),
      locale: const Locale('en'),
    );

    await tester.pumpWidget(bootstrap.createApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('account-email-field')), email);
    await tester.enterText(
      find.byKey(const Key('account-password-field')),
      password,
    );
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('Add your first pet'), findsOneWidget);
  });
}
