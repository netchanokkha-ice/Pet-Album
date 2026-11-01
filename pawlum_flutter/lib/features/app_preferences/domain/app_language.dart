import 'package:flutter/widgets.dart';

enum AppLanguage {
  thai('th'),
  english('en');

  const AppLanguage(this.code);

  final String code;

  Locale get locale => Locale(code);

  static AppLanguage? tryParse(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return null;
  }

  static AppLanguage fromDeviceLocales(Iterable<Locale> locales) {
    for (final locale in locales) {
      final supported = tryParse(locale.languageCode);
      if (supported != null) return supported;
    }
    return AppLanguage.thai;
  }
}
