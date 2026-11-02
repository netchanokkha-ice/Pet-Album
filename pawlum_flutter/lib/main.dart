import 'package:flutter/widgets.dart';

import 'app/bootstrap/app_bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/database/pawlum_database.dart';
import 'features/app_preferences/data/drift_language_preference_store.dart';
import 'features/app_preferences/presentation/app_locale_controller.dart';

const _demoAccountEmailDigest =
    '4a07d5100027dc60139d308866a93541175eff95233ae636f7246eabea599251';
const _demoAccountPasswordDigest =
    '5ce85f9cc6d454c963ef3733b678f7b0a9fed881d75e579bade249ac9fb60c7d';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final database = PawlumDatabase();
  final localeController = await AppLocaleController.load(
    localStore: DriftLanguagePreferenceStore(database),
    deviceLocales: WidgetsBinding.instance.platformDispatcher.locales,
  );
  final bootstrap = AppBootstrap.demo(
    config: config,
    accountEmailDigest: _demoAccountEmailDigest,
    accountPasswordDigest: _demoAccountPasswordDigest,
    localeController: localeController,
  );

  runApp(bootstrap.createApp());
}
