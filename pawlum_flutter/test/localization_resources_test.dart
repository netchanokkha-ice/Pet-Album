import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/l10n/app_localizations.dart';

void main() {
  test(
    'Thai and English ARB resources contain the same complete key set',
    () async {
      final english = await _readArb('lib/l10n/app_en.arb');
      final thai = await _readArb('lib/l10n/app_th.arb');
      final englishKeys = _messageKeys(english);
      final thaiKeys = _messageKeys(thai);

      expect(thaiKeys.difference(englishKeys), isEmpty);
      expect(englishKeys.difference(thaiKeys), isEmpty);
      expect(englishKeys.length, greaterThanOrEqualTo(180));
      for (final prefix in <String>[
        'account_',
        'onboarding_',
        'home_',
        'memory_',
        'timeline_',
        'recently_deleted_',
        'settings_',
        'a11y_',
      ]) {
        expect(
          englishKeys.any((String key) => key.startsWith(prefix)),
          isTrue,
          reason: 'Missing Phase 1 localization namespace $prefix',
        );
      }
      for (final key in englishKeys) {
        expect(
          (english[key] as String).trim(),
          isNotEmpty,
          reason: 'Empty en:$key',
        );
        expect(
          (thai[key] as String).trim(),
          isNotEmpty,
          reason: 'Empty th:$key',
        );
      }
    },
  );

  test(
    'generated localization delegate loads both supported languages',
    () async {
      final english = await AppLocalizations.delegate.load(const Locale('en'));
      final thai = await AppLocalizations.delegate.load(const Locale('th'));

      expect(AppLocalizations.supportedLocales, const <Locale>[
        Locale('en'),
        Locale('th'),
      ]);
      expect(english.settings_title, 'Settings');
      expect(thai.settings_title, 'ตั้งค่า');
      expect(
        english.verification_email_body('m@example.com'),
        contains('m@example.com'),
      );
      expect(thai.recently_deleted_days_left(3), 'เหลือ 3 วัน');
    },
  );
}

Future<Map<String, Object?>> _readArb(String path) async =>
    (jsonDecode(await File(path).readAsString()) as Map<String, Object?>);

Set<String> _messageKeys(Map<String, Object?> arb) =>
    arb.keys.where((String key) => !key.startsWith('@')).toSet();
