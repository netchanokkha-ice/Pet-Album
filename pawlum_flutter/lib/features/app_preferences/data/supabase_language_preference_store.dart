import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app_language.dart';
import '../domain/language_preference_store.dart';

class SupabaseLanguagePreferenceStore implements RemoteLanguagePreferenceStore {
  const SupabaseLanguagePreferenceStore(this._client);

  final SupabaseClient _client;

  @override
  Future<AppLanguage?> loadForAccount(String accountId) async {
    final row = await _client
        .from('user_preferences')
        .select('language_code')
        .eq('user_id', accountId)
        .maybeSingle();
    return AppLanguage.tryParse(row?['language_code'] as String?);
  }

  @override
  Future<void> saveForAccount(String accountId, AppLanguage language) async {
    await _client.from('user_preferences').upsert(<String, Object?>{
      'user_id': accountId,
      'language_code': language.code,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }
}
