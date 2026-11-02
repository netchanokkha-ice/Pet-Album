import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/bootstrap/app_bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/database/pawlum_database.dart';
import 'features/app_preferences/data/drift_language_preference_store.dart';
import 'features/app_preferences/data/supabase_language_preference_store.dart';
import 'features/app_preferences/presentation/app_locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  if (!config.hasSupabaseCredentials) {
    throw StateError(
      'SUPABASE_PUBLISHABLE_KEY must be provided with --dart-define.',
    );
  }
  await Supabase.initialize(
    url: config.supabaseUrl,
    publishableKey: config.supabasePublishableKey,
  );
  final supabase = Supabase.instance.client;
  final database = PawlumDatabase();
  final localeController = await AppLocaleController.load(
    localStore: DriftLanguagePreferenceStore(database),
    remoteStore: SupabaseLanguagePreferenceStore(supabase),
    deviceLocales: WidgetsBinding.instance.platformDispatcher.locales,
  );
  final bootstrap = AppBootstrap.production(
    config: config,
    supabase: supabase,
    database: database,
    localeController: localeController,
  );

  runApp(bootstrap.createApp());
}
