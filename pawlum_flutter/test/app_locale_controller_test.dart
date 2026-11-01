import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/core/database/pawlum_database.dart';
import 'package:pawlum/features/app_preferences/data/drift_language_preference_store.dart';
import 'package:pawlum/features/app_preferences/data/in_memory_language_preference_store.dart';
import 'package:pawlum/features/app_preferences/domain/app_language.dart';
import 'package:pawlum/features/app_preferences/presentation/app_locale_controller.dart';

import 'helpers/pump_pawlum_app.dart';

void main() {
  tearDown(Get.reset);

  test(
    'launch defaults to a supported device locale and persists it',
    () async {
      final local = InMemoryLocalLanguagePreferenceStore();

      final controller = await AppLocaleController.load(
        localStore: local,
        deviceLocales: const <Locale>[Locale('ja'), Locale('en', 'GB')],
      );

      expect(controller.language, AppLanguage.english);
      expect(local.language, AppLanguage.english);
      expect(local.loadCount, 1);
      expect(local.saveCount, 1);
    },
  );

  test(
    'relaunch uses the local choice before a changed device locale',
    () async {
      final local = InMemoryLocalLanguagePreferenceStore(AppLanguage.thai);

      final controller = await AppLocaleController.load(
        localStore: local,
        deviceLocales: const <Locale>[Locale('en')],
      );

      expect(controller.language, AppLanguage.thai);
      expect(local.saveCount, 0);
    },
  );

  testWidgets(
    'cross-device account preference is resolved before the first app frame',
    (tester) async {
      const accountId = 'account-a';
      final remote = InMemoryRemoteLanguagePreferenceStore()
        ..values[accountId] = AppLanguage.english;
      final secondDeviceLocal = InMemoryLocalLanguagePreferenceStore(
        AppLanguage.thai,
      );

      final controller = await AppLocaleController.load(
        localStore: secondDeviceLocal,
        remoteStore: remote,
        accountId: accountId,
        deviceLocales: const <Locale>[Locale('th')],
      );
      await tester.pumpPawlumApp(localeController: controller);

      expect(controller.language, AppLanguage.english);
      expect(secondDeviceLocal.language, AppLanguage.english);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('เข้าสู่ระบบ'), findsNothing);
    },
  );

  test(
    'language changes save locally before the remote account value',
    () async {
      const accountId = 'account-a';
      final local = InMemoryLocalLanguagePreferenceStore(AppLanguage.thai);
      final remote = InMemoryRemoteLanguagePreferenceStore();
      final controller = await AppLocaleController.load(
        localStore: local,
        remoteStore: remote,
        accountId: accountId,
        deviceLocales: const <Locale>[Locale('th')],
      );

      await controller.setLanguage(AppLanguage.english);

      expect(controller.language, AppLanguage.english);
      expect(local.language, AppLanguage.english);
      expect(remote.values[accountId], AppLanguage.english);
    },
  );

  test('Drift preference survives a database restart', () async {
    final directory = await Directory.systemTemp.createTemp(
      'pawlum-locale-test-',
    );
    final file = File(
      '${directory.path}${Platform.pathSeparator}pawlum.sqlite',
    );
    final firstDatabase = PawlumDatabase.forTesting(NativeDatabase(file));
    final firstStore = DriftLanguagePreferenceStore(firstDatabase);

    await firstStore.save(AppLanguage.english);
    await firstDatabase.close();

    final secondDatabase = PawlumDatabase.forTesting(NativeDatabase(file));
    final secondStore = DriftLanguagePreferenceStore(secondDatabase);
    expect(await secondStore.load(), AppLanguage.english);

    await secondDatabase.close();
    await directory.delete(recursive: true);
  });
}
