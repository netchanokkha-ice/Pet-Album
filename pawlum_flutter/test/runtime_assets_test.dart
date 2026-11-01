import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const fontAssets = <String>[
    'assets/fonts/Jua-Regular.ttf',
    'assets/fonts/Itim-Regular.ttf',
    'assets/fonts/Caveat-Variable.ttf',
  ];

  const licenseAssets = <String>[
    'assets/fonts/licenses/Jua-OFL.txt',
    'assets/fonts/licenses/Itim-OFL.txt',
    'assets/fonts/licenses/Caveat-OFL.txt',
  ];

  test('every declared Pawlum font and license asset loads', () async {
    for (final assetPath in fontAssets) {
      final data = await rootBundle.load(assetPath);

      expect(data.lengthInBytes, greaterThan(1000), reason: assetPath);
      expect(
        data.buffer.asUint8List(0, 4),
        orderedEquals(const <int>[0, 1, 0, 0]),
        reason: '$assetPath must be a valid TrueType font',
      );
    }

    for (final assetPath in licenseAssets) {
      final license = await rootBundle.loadString(assetPath);

      expect(
        license,
        contains('SIL OPEN FONT LICENSE Version 1.1'),
        reason: assetPath,
      );
    }
  });
}
