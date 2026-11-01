import 'app_language.dart';

abstract interface class LocalLanguagePreferenceStore {
  Future<AppLanguage?> load();

  Future<void> save(AppLanguage language);
}

abstract interface class RemoteLanguagePreferenceStore {
  Future<AppLanguage?> loadForAccount(String accountId);

  Future<void> saveForAccount(String accountId, AppLanguage language);
}
