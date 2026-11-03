import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/features/app_shell/domain/entities/app_readiness.dart';
import 'package:pawlum/features/pet_profiles/data/repositories/in_memory_pet_onboarding_draft_repository.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_models.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_onboarding_draft.dart';
import 'package:pawlum/features/pet_profiles/presentation/controllers/pet_onboarding_controller.dart';

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

    await tester.tap(find.text('Start with their name'));
    await tester.pumpAndSettle();
    expect(find.text('What should we call your pet?'), findsOneWidget);

    await tester.tap(find.text('That’s their name'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your pet’s name to continue'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('pet-name-field')), 'Mochi');
    await tester.tap(find.text('That’s their name'));
    await tester.pumpAndSettle();
    expect(find.text('What kind of pet is Mochi?'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a pet type to continue'), findsOneWidget);

    await tester.tap(find.text('Cat'));
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('When was Mochi born?'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('What kind of pet is Mochi?'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('What should we call your pet?'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('pet-name-field')))
          .controller!
          .text,
      'Mochi',
    );

    await tester.tap(find.text('That’s their name'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Skip for now'));
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(find.text('When did you first meet Mochi?'), findsOneWidget);
    await tester.ensureVisible(find.text('Skip for now'));
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(find.text('Which photo feels most like Mochi?'), findsOneWidget);
    await tester.ensureVisible(find.text('Skip for now'));
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(find.text('Mochi’s journal is ready'), findsOneWidget);
    expect(find.text('Mochi'), findsOneWidget);
    expect(find.text('Ready for the first page'), findsOneWidget);
    await tester.ensureVisible(find.text('Create Mochi’s journal'));
    await tester.tap(find.text('Create Mochi’s journal'));
    await tester.pumpAndSettle();
    expect(confirmedDraft?.name, 'Mochi');
  });

  testWidgets('Choose photo uses the onboarding picker and updates the draft', (
    WidgetTester tester,
  ) async {
    final picker = _RecordingPetPhotoPicker();
    await tester.pumpPawlumApp(
      readiness: onboardingRequired,
      onboardingPhotoPicker: picker,
    );
    await _openOnboarding(tester);
    await _reachPhotoQuestion(tester, name: 'Mochi', type: PetType.cat);

    await tester.tap(find.text('Choose photo'));
    await tester.pumpAndSettle();

    expect(picker.calls, 1);
    expect(find.text('Change photo'), findsOneWidget);
  });

  testWidgets('turning a question uses the notebook page-flip transition', (
    WidgetTester tester,
  ) async {
    await tester.pumpPawlumApp(readiness: onboardingRequired);
    await _openOnboarding(tester);

    await tester.tap(find.text('Start with their name'));
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.byKey(const Key('onboarding-page-flip')), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('What should we call your pet?'), findsOneWidget);
  });

  testWidgets('Other type requires a custom label', (
    WidgetTester tester,
  ) async {
    await tester.pumpPawlumApp(readiness: onboardingRequired);
    await _openOnboarding(tester);
    await tester.tap(find.text('Start with their name'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('pet-name-field')), 'Pip');
    await tester.tap(find.text('That’s their name'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other'));
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('other-type-field')), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Tell us what kind of pet this is'), findsOneWidget);
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
    await tester.tap(find.text('Start with their name'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('pet-name-field')), 'Mochi');

    await tester.tap(find.text('Save & leave'));
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
    await _reachPhotoQuestion(tester, name: 'Mochi', type: PetType.cat);
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
    expect(find.text('Which photo feels most like Mochi?'), findsOneWidget);
    expect(find.text('Mochi'), findsOneWidget);
  });

  testWidgets('local draft restores the exact unanswered question', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryPetOnboardingDraftRepository();

    await tester.pumpPawlumApp(
      readiness: onboardingRequired,
      onboardingDraftRepository: repository,
    );
    await _openOnboarding(tester);
    await tester.tap(find.text('Start with their name'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('pet-name-field')), 'Mochi');
    await tester.tap(find.text('That’s their name'));
    await tester.pumpAndSettle();
    expect(find.text('What kind of pet is Mochi?'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
    await tester.pumpPawlumApp(
      readiness: onboardingRequired,
      onboardingDraftRepository: repository,
    );
    await tester.tap(find.text('Create pet profile'));
    await tester.pumpAndSettle();

    expect(find.text('What kind of pet is Mochi?'), findsOneWidget);
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

  testWidgets('pet name question matches its phone golden', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpPawlumApp(readiness: onboardingRequired);
    await _openOnboarding(tester);
    await tester.tap(find.text('Start with their name'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold).last,
      matchesGoldenFile('goldens/pet_onboarding_name_phone.png'),
    );
  });
}

Future<void> _openOnboarding(WidgetTester tester) async {
  await tester.tap(find.text('Create pet profile'));
  await tester.pumpAndSettle();
  expect(find.text('Let’s meet your pet'), findsOneWidget);
}

Future<void> _reachPhotoQuestion(
  WidgetTester tester, {
  required String name,
  required PetType type,
}) async {
  await tester.tap(find.text('Start with their name'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('pet-name-field')), name);
  await tester.tap(find.text('That’s their name'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(_petTypeLabel(type)));
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Skip for now'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Skip for now'));
  await tester.pumpAndSettle();
}

String _petTypeLabel(PetType type) => switch (type) {
  PetType.dog => 'Dog',
  PetType.cat => 'Cat',
  PetType.bird => 'Bird',
  PetType.rabbit => 'Rabbit',
  PetType.other => 'Other',
};

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

class _RecordingPetPhotoPicker implements PetPhotoPicker {
  int calls = 0;

  @override
  Future<PetPhotoSelection?> pickPhoto() async {
    calls += 1;
    return PetPhotoSelection(
      bytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=',
      ),
      fileName: 'mochi.png',
      mimeType: 'image/png',
    );
  }
}
