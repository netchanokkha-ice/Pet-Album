import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/features/app_shell/domain/entities/app_readiness.dart';
import 'package:pawlum/features/pet_profiles/data/repositories/in_memory_pet_onboarding_draft_repository.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_onboarding_draft.dart';

import 'helpers/pump_pawlum_app.dart';

void main() {
  setUpAll(_loadGoldenFonts);
  tearDown(Get.reset);

  const onboardingRequired = AppReadiness(
    isAuthenticated: true,
    petCount: 0,
    pendingDraftCount: 0,
  );

  testWidgets('moves forward and back while retaining entered pet details', (
    WidgetTester tester,
  ) async {
    PetOnboardingDraft? confirmedDraft;
    await tester.pumpPawlumApp(
      readiness: onboardingRequired,
      onPetOnboardingConfirm: (PetOnboardingDraft draft) async {
        confirmedDraft = draft;
      },
    );
    await _openOnboarding(tester);

    await tester.tap(find.text('Begin pet setup'));
    await tester.pumpAndSettle();
    expect(find.text('Tell us about your pet'), findsOneWidget);

    await tester.ensureVisible(find.text('Continue to photo'));
    await tester.tap(find.text('Continue to photo'));
    await tester.pumpAndSettle();
    expect(find.text('Pet name is required'), findsOneWidget);
    expect(find.text('Choose a pet type'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('pet-name-field')), 'Mochi');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Cat'));
    await tester.ensureVisible(find.text('Continue to photo'));
    await tester.tap(find.text('Continue to photo'));
    await tester.pumpAndSettle();
    expect(find.text('Add a favorite photo'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Tell us about your pet'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('pet-name-field')))
          .controller!
          .text,
      'Mochi',
    );

    await tester.ensureVisible(find.text('Continue to photo'));
    await tester.tap(find.text('Continue to photo'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Skip for now'));
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(find.text('Your journal is ready to begin'), findsOneWidget);
    expect(find.text('Mochi'), findsOneWidget);
    expect(find.text('First memory'), findsOneWidget);
    await tester.ensureVisible(find.text('Confirm first memory'));
    await tester.tap(find.text('Confirm first memory'));
    await tester.pumpAndSettle();
    expect(confirmedDraft?.name, 'Mochi');
  });

  testWidgets('Other type requires a custom label', (
    WidgetTester tester,
  ) async {
    await tester.pumpPawlumApp(readiness: onboardingRequired);
    await _openOnboarding(tester);
    await tester.tap(find.text('Begin pet setup'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('pet-name-field')), 'Pip');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Other'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('other-type-field')), findsOneWidget);
    await tester.ensureVisible(find.text('Continue to photo'));
    await tester.tap(find.text('Continue to photo'));
    await tester.pumpAndSettle();
    expect(find.text('Custom pet type is required'), findsOneWidget);
  });

  testWidgets('discard cancellation clears the recoverable draft', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryPetOnboardingDraftRepository();
    await tester.pumpPawlumApp(
      readiness: onboardingRequired,
      onboardingDraftRepository: repository,
    );
    await _openOnboarding(tester);
    await tester.tap(find.text('Begin pet setup'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('pet-name-field')), 'Mochi');

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Leave pet setup?'), findsOneWidget);
    await tester.tap(find.text('Discard setup'));
    await tester.pumpAndSettle();

    expect(find.text('Add your first pet'), findsOneWidget);
    expect(await repository.load('fake-verified-account'), isNull);
  });

  testWidgets('local draft restores the current step after app restart', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryPetOnboardingDraftRepository();

    await tester.pumpPawlumApp(
      readiness: onboardingRequired,
      onboardingDraftRepository: repository,
    );
    await _openOnboarding(tester);
    await tester.tap(find.text('Begin pet setup'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('pet-name-field')), 'Mochi');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Cat'));
    await tester.ensureVisible(find.text('Continue to photo'));
    await tester.tap(find.text('Continue to photo'));
    await tester.pumpAndSettle();
    expect(
      (await repository.load('fake-verified-account'))?.step,
      PetOnboardingStep.photo,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();

    await tester.pumpPawlumApp(
      readiness: onboardingRequired,
      onboardingDraftRepository: repository,
    );
    await tester.tap(find.text('Create pet profile'));
    await tester.pumpAndSettle();
    expect(find.text('Add a favorite photo'), findsOneWidget);
    expect(find.text('Mochi'), findsOneWidget);
  });

  testWidgets('pet onboarding welcome matches its phone golden', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpPawlumApp(readiness: onboardingRequired);
    await _openOnboarding(tester);

    await expectLater(
      find.byType(Scaffold).last,
      matchesGoldenFile('goldens/pet_onboarding_welcome_phone.png'),
    );
  });
}

Future<void> _openOnboarding(WidgetTester tester) async {
  await tester.tap(find.text('Create pet profile'));
  await tester.pumpAndSettle();
  expect(find.text('Let’s meet your pet'), findsOneWidget);
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
