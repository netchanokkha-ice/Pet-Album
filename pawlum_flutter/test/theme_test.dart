import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/core/theme/pawlum_theme.dart';
import 'package:pawlum/core/theme/pawlum_tokens.dart';
import 'package:pawlum/core/theme/pawlum_typography.dart';

void main() {
  test('light theme preserves the Pawlum scrapbook surface and typography', () {
    final theme = PawlumTheme.lightForWidth(390);

    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, PawlumColors.canvas);
    expect(theme.cardTheme.color, PawlumColors.paper);
    expect(
      theme.textTheme.headlineLarge?.fontFamily,
      PawlumTypography.displayFamily,
    );
    expect(
      theme.textTheme.headlineLarge?.fontFamilyFallback,
      contains(PawlumTypography.bodyFamily),
    );
    expect(theme.textTheme.bodyLarge?.fontFamily, PawlumTypography.bodyFamily);
  });

  test(
    'responsive layout tokens select compact, medium, and expanded themes',
    () {
      final compact = PawlumTheme.lightForWidth(
        390,
      ).extension<PawlumLayoutTheme>()!;
      final medium = PawlumTheme.lightForWidth(
        800,
      ).extension<PawlumLayoutTheme>()!;
      final expanded = PawlumTheme.lightForWidth(
        1200,
      ).extension<PawlumLayoutTheme>()!;

      expect(compact.windowClass, PawlumWindowClass.compact);
      expect(compact.pagePadding.horizontal, 40);
      expect(medium.windowClass, PawlumWindowClass.medium);
      expect(medium.pagePadding.horizontal, 64);
      expect(expanded.windowClass, PawlumWindowClass.expanded);
      expect(expanded.contentMaxWidth, 960);
    },
  );

  testWidgets('Thai fallback and 200 percent text scaling remain usable', (
    tester,
  ) async {
    final theme = PawlumTheme.lightForWidth(390);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(PawlumSpacing.lg),
              children: [
                Text(
                  'บันทึกเรื่องราวของน้องโมจิ',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: PawlumSpacing.md),
                Text(
                  'ทุกช่วงเวลาธรรมดากลายเป็นความทรงจำที่กลับมาอ่านได้เสมอ',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final heading = tester.widget<Text>(
      find.text('บันทึกเรื่องราวของน้องโมจิ'),
    );
    final mediaQuery = MediaQuery.of(tester.element(find.byType(Scaffold)));

    expect(
      heading.style?.fontFamilyFallback,
      contains(PawlumTypography.bodyFamily),
    );
    expect(mediaQuery.textScaler.scale(16), 32);
    expect(tester.takeException(), isNull);
  });
}
