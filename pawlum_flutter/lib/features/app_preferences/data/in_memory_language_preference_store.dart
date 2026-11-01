import '../domain/app_language.dart';
import '../domain/language_preference_store.dart';

class InMemoryLocalLanguagePreferenceStore
    implements LocalLanguagePreferenceStore {
  InMemoryLocalLanguagePreferenceStore([this.language]);

  AppLanguage? language;
  int loadCount = 0;
  int saveCount = 0;

  @override
  Future<AppLanguage?> load() async {
    loadCount += 1;
    return language;
  }

  @override
  Future<void> save(AppLanguage language) async {
    saveCount += 1;
    this.language = language;
  }
}

class InMemoryRemoteLanguagePreferenceStore
    implements RemoteLanguagePreferenceStore {
  final Map<String, AppLanguage> values = <String, AppLanguage>{};

  @override
  Future<AppLanguage?> loadForAccount(String accountId) async =>
      values[accountId];

  @override
  Future<void> saveForAccount(String accountId, AppLanguage language) async {
    values[accountId] = language;
  }
}
