import '../../../core/database/pawlum_database.dart';
import '../domain/app_language.dart';
import '../domain/language_preference_store.dart';

class DriftLanguagePreferenceStore implements LocalLanguagePreferenceStore {
  DriftLanguagePreferenceStore(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const _languageKey = 'language_code';

  final PawlumDatabase _database;
  final DateTime Function() _now;

  @override
  Future<AppLanguage?> load() async {
    final row =
        await (_database.select(_database.appPreferences)
              ..where((AppPreferences table) => table.key.equals(_languageKey)))
            .getSingleOrNull();
    return AppLanguage.tryParse(row?.value);
  }

  @override
  Future<void> save(AppLanguage language) async {
    await _database
        .into(_database.appPreferences)
        .insertOnConflictUpdate(
          AppPreferencesCompanion.insert(
            key: _languageKey,
            value: language.code,
            updatedAt: _now().toUtc(),
          ),
        );
  }
}
