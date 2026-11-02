@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/core/database/pawlum_database.dart';

void main() {
  test('default Pawlum database opens in a browser', () async {
    final database = PawlumDatabase();
    addTearDown(database.close);

    expect(await database.select(database.appPreferences).get(), isEmpty);
  });
}
