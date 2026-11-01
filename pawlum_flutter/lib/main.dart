import 'package:flutter/widgets.dart';

import 'app/bootstrap/app_bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/database/pawlum_database.dart';
import 'features/app_preferences/data/drift_language_preference_store.dart';
import 'features/app_preferences/presentation/app_locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final database = PawlumDatabase();
  final localeController = await AppLocaleController.load(
    localStore: DriftLanguagePreferenceStore(database),
    deviceLocales: WidgetsBinding.instance.platformDispatcher.locales,
  );
  final bootstrap = AppBootstrap.fake(
    config: config,
    localeController: localeController,
  );

  runApp(bootstrap.createApp());
}
