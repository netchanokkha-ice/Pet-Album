import 'package:flutter/widgets.dart';

import '../domain/app_language.dart';
import '../domain/language_preference_store.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController._(
    this._language,
    this._localStore,
    this._remoteStore,
    this._accountId,
  );

  final LocalLanguagePreferenceStore _localStore;
  final RemoteLanguagePreferenceStore? _remoteStore;

  AppLanguage _language;
  String? _accountId;

  AppLanguage get language => _language;
  Locale get locale => _language.locale;

  static Future<AppLocaleController> load({
    required LocalLanguagePreferenceStore localStore,
    required Iterable<Locale> deviceLocales,
    RemoteLanguagePreferenceStore? remoteStore,
    String? accountId,
  }) async {
    final stored = await localStore.load();
    var selected = stored ?? AppLanguage.fromDeviceLocales(deviceLocales);
    if (stored == null) {
      await localStore.save(selected);
    }

    if (accountId != null && remoteStore != null) {
      try {
        final remote = await remoteStore.loadForAccount(accountId);
        if (remote == null) {
          await remoteStore.saveForAccount(accountId, selected);
        } else if (remote != selected) {
          selected = remote;
          await localStore.save(selected);
        }
      } on Object {
        // An unavailable account preference must not block a local launch.
      }
    }

    return AppLocaleController._(selected, localStore, remoteStore, accountId);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (language == _language) return;

    await _localStore.save(language);
    _language = language;
    notifyListeners();

    final accountId = _accountId;
    final remoteStore = _remoteStore;
    if (accountId != null && remoteStore != null) {
      await remoteStore.saveForAccount(accountId, language);
    }
  }

  Future<void> attachAccount(String accountId) async {
    _accountId = accountId;
    final remoteStore = _remoteStore;
    if (remoteStore == null) return;

    final remote = await remoteStore.loadForAccount(accountId);
    if (remote == null) {
      await remoteStore.saveForAccount(accountId, _language);
      return;
    }
    if (remote == _language) return;

    await _localStore.save(remote);
    _language = remote;
    notifyListeners();
  }

  void detachAccount() => _accountId = null;
}
