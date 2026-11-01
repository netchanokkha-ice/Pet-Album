import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/core/theme/pawlum_theme.dart';
import 'package:pawlum/core/theme/pawlum_tokens.dart';
import 'package:pawlum/core/widgets/pawlum_widgets.dart';

void main() {
  setUpAll(_loadGoldenFonts);

  testWidgets('scrapbook primitives expose actions and meaningful semantics', (
    tester,
  ) async {
    var primaryPresses = 0;
    final semantics = tester.ensureSemantics();

    await _pumpShowcase(
      tester,
      const Size(390, 844),
      onPrimaryPressed: () => primaryPresses += 1,
    );

    expect(
      find.bySemanticsLabel('Photo placeholder for Mochi'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Memory date 26 May 2026'), findsOneWidget);
    expect(find.bySemanticsLabel('Draft'), findsOneWidget);
    expect(find.bySemanticsLabel('Loading memory preview'), findsOneWidget);

    await tester.tap(find.text('Add memory'));
    await tester.pump();

    expect(primaryPresses, 1);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('components adapt from phone to tablet constraints', (
    tester,
  ) async {
    await _pumpShowcase(tester, const Size(390, 844));
    final compactContext = tester.element(find.text('Pawlum keepsakes'));

    expect(
      PawlumLayoutTheme.of(compactContext).windowClass,
      PawlumWindowClass.compact,
    );
    expect(tester.takeException(), isNull);

    await _pumpShowcase(tester, const Size(900, 1100));
    final tabletContext = tester.element(find.text('Pawlum keepsakes'));

    expect(
      PawlumLayoutTheme.of(tabletContext).windowClass,
      PawlumWindowClass.medium,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone component showcase matches its golden', (tester) async {
    await _pumpShowcase(tester, const Size(390, 844));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/pawlum_components_phone.png'),
    );
  });

  testWidgets('tablet component showcase matches its golden', (tester) async {
    await _pumpShowcase(tester, const Size(900, 1100));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/pawlum_components_tablet.png'),
    );
  });
}

Future<void> _loadGoldenFonts() async {
  final fonts = <(String, String)>[
    ('PawlumJua', 'assets/fonts/Jua-Regular.ttf'),
    ('PawlumItim', 'assets/fonts/Itim-Regular.ttf'),
    ('PawlumCaveat', 'assets/fonts/Caveat-Variable.ttf'),
    ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
  ];

  for (final (family, assetPath) in fonts) {
    final loader = FontLoader(family)..addFont(rootBundle.load(assetPath));
    await loader.load();
  }
}

Future<void> _pumpShowcase(
  WidgetTester tester,
  Size size, {
  VoidCallback? onPrimaryPressed,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: PawlumTheme.lightForWidth(size.width),
      home: Scaffold(
        body: PawlumPaperBackground(
          child: _ComponentShowcase(
            onPrimaryPressed: onPrimaryPressed ?? () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _ComponentShowcase extends StatelessWidget {
  const _ComponentShowcase({required this.onPrimaryPressed});

  final VoidCallback onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    final layout = PawlumLayoutTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: layout.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PawlumWashiTape(label: 'little moments, big love'),
              const SizedBox(height: PawlumSpacing.md),
              Text('Pawlum keepsakes', style: textTheme.headlineLarge),
              const SizedBox(height: PawlumSpacing.xs),
              Text(
                'Warm, private building blocks for every pet story.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: PawlumSpacing.lg),
              const Wrap(
                spacing: PawlumSpacing.sm,
                runSpacing: PawlumSpacing.sm,
                children: [
                  PawlumStickerLabel(
                    label: 'First memory',
                    icon: Icons.auto_awesome_rounded,
                  ),
                  PawlumStatusBadge(status: PawlumStatus.draft),
                  PawlumStatusBadge(status: PawlumStatus.synced),
                  PawlumStatusBadge(status: PawlumStatus.pending),
                ],
              ),
              const SizedBox(height: PawlumSpacing.lg),
              const PawlumRibbon(label: 'May 2026'),
              const SizedBox(height: PawlumSpacing.lg),
              Wrap(
                spacing: PawlumSpacing.lg,
                runSpacing: PawlumSpacing.lg,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const PawlumPetPlaceholder(
                    semanticLabel: 'Photo placeholder for Mochi',
                    size: 92,
                  ),
                  const PawlumDateStamp(
                    day: '26',
                    month: 'May',
                    year: '2026',
                    semanticLabel: 'Memory date 26 May 2026',
                  ),
                  SizedBox(
                    width: layout.windowClass == PawlumWindowClass.compact
                        ? 220
                        : 260,
                    child: const PawlumPolaroidCard(
                      caption: 'Mochi found the sunny window',
                      semanticLabel: 'Memory photo: Mochi by the sunny window',
                      rotation: -0.018,
                      media: ColoredBox(
                        color: PawlumColors.purple,
                        child: Center(
                          child: Icon(
                            Icons.photo_rounded,
                            size: 44,
                            color: PawlumColors.purpleStrong,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PawlumSpacing.xl),
              Wrap(
                spacing: PawlumSpacing.sm,
                runSpacing: PawlumSpacing.sm,
                children: [
                  PawlumPrimaryButton(
                    label: 'Add memory',
                    icon: Icons.add_rounded,
                    onPressed: onPrimaryPressed,
                  ),
                  PawlumGhostButton(label: 'Back', onPressed: () {}),
                ],
              ),
              const SizedBox(height: PawlumSpacing.xl),
              const PawlumSkeleton(
                width: double.infinity,
                height: 18,
                semanticLabel: 'Loading memory preview',
              ),
              const SizedBox(height: PawlumSpacing.xs),
              const PawlumSkeleton(width: 210, height: 14),
              const SizedBox(height: PawlumSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
