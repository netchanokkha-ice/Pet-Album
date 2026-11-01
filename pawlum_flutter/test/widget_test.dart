import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/core/config/app_config.dart';

import 'helpers/pump_pawlum_app.dart';

void main() {
  tearDown(Get.reset);

  test('test configuration does not require Supabase credentials', () {
    final config = AppConfig.test();

    expect(config.hasSupabaseCredentials, isFalse);
    expect(config.useFakeRepositories, isTrue);
  });

  testWidgets('fake bootstrap launches the signed-out Pawlum shell', (
    tester,
  ) async {
    await tester.pumpPawlumApp();

    expect(find.text('Welcome to Pawlum'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
