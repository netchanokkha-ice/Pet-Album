import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/features/account_access/data/repositories/in_memory_account_repository.dart';
import 'package:pawlum/features/account_access/domain/entities/account_identity.dart';
import 'package:pawlum/features/app_preferences/data/in_memory_language_preference_store.dart';
import 'package:pawlum/features/app_preferences/domain/app_language.dart';
import 'package:pawlum/features/app_preferences/presentation/app_locale_controller.dart';
import 'package:pawlum/features/app_shell/domain/entities/app_readiness.dart';
import 'package:pawlum/features/app_shell/presentation/controllers/app_shell_controller.dart';
import 'package:pawlum/features/memory_authoring/data/in_memory_memory_authoring_draft_repository.dart';
import 'package:pawlum/features/memory_authoring/data/in_memory_memory_lifecycle_repository.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_media_selection.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_models.dart';
import 'package:pawlum/features/memory_authoring/presentation/controllers/memory_authoring_controller.dart';
import 'package:pawlum/features/memory_authoring/presentation/controllers/memory_lifecycle_controller.dart';
import 'package:pawlum/features/pet_profiles/data/repositories/in_memory_pet_profile_repository.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_models.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_onboarding_draft.dart';
import 'package:pawlum/features/pet_profiles/domain/repositories/pet_profile_repository.dart';
import 'package:pawlum/features/pet_profiles/presentation/controllers/pet_home_controller.dart';
import 'package:pawlum/features/timeline/data/in_memory_timeline_repository.dart';
import 'package:pawlum/features/timeline/domain/entities/timeline_models.dart';
import 'package:pawlum/features/timeline/presentation/controllers/timeline_controller.dart';

import 'helpers/pump_pawlum_app.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('complete Phase 1 journey is deterministic on the fake backend', (
    tester,
  ) async {
    const accountId = 'account-e2e';
    final now = DateTime.utc(2026, 11, 1, 9);
    final accountRepository =
        InMemoryAccountRepository(
          now: () => now,
          sessionDuration: const Duration(days: 30),
        )..seedAccount(
          account: const AccountIdentity(
            id: accountId,
            email: 'journal@pawlum.test',
            isEmailVerified: true,
            authMethods: <AccountAuthMethod>{AccountAuthMethod.emailPassword},
          ),
          password: 'safe-password',
        );
    final petRepository = InMemoryPetProfileRepository();
    await petRepository.initializePetJournal(
      InitializePetJournalCommand(
        accountId: accountId,
        petId: 'pet-mochi',
        firstMemoryId: 'first-mochi',
        input: const PetOnboardingInput(name: 'Mochi', type: PetType.cat),
        createdAt: now,
      ),
    );
    final memoryRepository = InMemoryMemoryLifecycleRepository();
    final timelineRepository = InMemoryTimelineRepository();
    final localLanguage = InMemoryLocalLanguagePreferenceStore(
      AppLanguage.english,
    );
    final remoteLanguage = InMemoryRemoteLanguagePreferenceStore();
    final localeController = await AppLocaleController.load(
      localStore: localLanguage,
      remoteStore: remoteLanguage,
      accountId: accountId,
      deviceLocales: const <Locale>[Locale('en')],
    );

    await tester.pumpPawlumApp(
      readiness: const AppReadiness(
        isAuthenticated: false,
        petCount: 1,
        pendingDraftCount: 0,
      ),
      accountRepository: accountRepository,
      petProfileRepository: petRepository,
      memoryLifecycleRepository: memoryRepository,
      timelineRepository: timelineRepository,
      localeController: localeController,
      onPetOnboardingConfirm: (PetOnboardingDraft draft) async {
        await petRepository.initializePetJournal(
          InitializePetJournalCommand(
            accountId: accountId,
            petId: 'pet-luna',
            firstMemoryId: 'first-luna',
            input: draft.input,
            createdAt: now.add(const Duration(minutes: 1)),
          ),
        );
        await Get.find<PetHomeController>().load();
        Get.back<void>();
      },
    );

    // Sign in through the real account page and return to the journal shell.
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('account-email-field')),
      'journal@pawlum.test',
    );
    await tester.enterText(
      find.byKey(const Key('account-password-field')),
      'safe-password',
    );
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();
    expect(accountRepository.hasStoredSession, isTrue);
    expect(
      Get.find<AppShellController>().readiness.value?.isAuthenticated,
      isTrue,
    );
    expect(
      Get.find<AppShellController>().destination.value,
      AppShellDestination.home,
    );
    expect(
      find.text('Mochi'),
      findsOneWidget,
      reason: tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) => widget.data)
          .whereType<String>()
          .join(' | '),
    );

    // Add a second pet through onboarding.
    await tester.tap(find.text('Add pet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Begin pet setup'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('pet-name-field')), 'Luna');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Cat'));
    await tester.ensureVisible(find.text('Continue to photo'));
    await tester.tap(find.text('Continue to photo'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Skip for now'));
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Confirm first memory'));
    await tester.tap(find.text('Confirm first memory'));
    await tester.pumpAndSettle();
    expect(find.text('Mochi'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);

    // Save an offline draft and restore it in a fresh controller, as on relaunch.
    final draftRepository = InMemoryMemoryAuthoringDraftRepository();
    final firstAuthoring = MemoryAuthoringController(
      picker: const _E2eMediaPicker(),
      draftRepository: draftRepository,
      accountId: accountId,
      draftId: 'draft-sunny-window',
      memoryId: 'memory-sunny-window',
      now: () => now.add(const Duration(minutes: 2)),
    );
    await firstAuthoring.addImages();
    firstAuthoring.next();
    firstAuthoring.next();
    firstAuthoring.setTitle('Sunny window nap');
    firstAuthoring.setCaption('Mochi and Luna shared the warmest spot.');
    await firstAuthoring.saveDraft();
    firstAuthoring.onClose();

    final relaunchedAuthoring = MemoryAuthoringController(
      picker: const _E2eMediaPicker(),
      draftRepository: draftRepository,
      accountId: accountId,
      draftId: 'draft-sunny-window',
      memoryId: 'memory-sunny-window',
      now: () => now.add(const Duration(minutes: 3)),
    );
    await relaunchedAuthoring.loadDraft();
    expect(relaunchedAuthoring.title.value, 'Sunny window nap');
    expect(relaunchedAuthoring.mediaSelection.value.activeMedia, hasLength(1));
    expect(relaunchedAuthoring.pendingSync.value, isTrue);

    // Publish, then promote an edit draft while preserving the published identity.
    final published = _publishRecoveredDraft(relaunchedAuthoring, now);
    final promoted = _promoteEditDraft(published, now);
    expect(promoted.currentPublishedVersion?.id, 'version-edited');
    expect(promoted.versionHistory.single.id, 'version-original');
    memoryRepository.seed(promoted);
    timelineRepository.seed(
      TimelineEntry(
        memoryId: promoted.id,
        visibleVersionId: promoted.currentPublishedVersion!.id,
        petId: 'pet-mochi',
        title: promoted.currentPublishedVersion!.title!,
        caption: promoted.currentPublishedVersion!.caption,
        memoryDate: promoted.currentPublishedVersion!.memoryDate,
        draftIndicator: TimelineDraftIndicator.none,
      ),
    );

    final lifecycle = Get.find<MemoryLifecycleController>();
    await lifecycle.load();
    await Get.find<TimelineController>().selectPet(
      id: 'pet-mochi',
      name: 'Mochi',
    );
    await tester.tap(find.text('Timeline').last);
    await tester.pumpAndSettle();
    expect(find.text('Sunny window nap — edited'), findsOneWidget);
    await tester.tap(find.text('Sunny window nap — edited'));
    await tester.pumpAndSettle();
    expect(find.text('A brighter caption after editing.'), findsOneWidget);

    // Delete and restore the same published memory through user-facing screens.
    await tester.tap(find.byTooltip('Back to timeline'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete Sunny window nap — edited'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to Recently Deleted'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Recently Deleted'));
    await tester.tap(find.text('Recently Deleted'));
    await tester.pumpAndSettle();
    expect(find.text('Sunny window nap — edited'), findsOneWidget);
    await tester.tap(find.text('Restore memory'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing to recover'), findsOneWidget);

    // Persist a language change and finish by signing out.
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Thai'));
    await tester.tap(find.text('Thai'));
    await tester.pumpAndSettle();
    expect(localeController.language, AppLanguage.thai);
    expect(remoteLanguage.values[accountId], AppLanguage.thai);
    await tester.ensureVisible(find.text('ออกจากระบบ'));
    await tester.tap(find.text('ออกจากระบบ'));
    await tester.pumpAndSettle();
    expect(find.text('เข้าสู่ระบบ'), findsOneWidget);
    expect(accountRepository.hasStoredSession, isFalse);
  });
}

MemoryAggregate _publishRecoveredDraft(
  MemoryAuthoringController controller,
  DateTime now,
) {
  final media =
      MemoryMedia.create(
            id: 'media-original',
            memoryVersionId: 'version-original',
            sourcePath: '/private/sunny-window.jpg',
            type: MemoryMediaType.image,
            sortOrder: 0,
            isCover: true,
            createdAt: now,
          )
          .queue(now.add(const Duration(seconds: 1)))
          .startUpload(now.add(const Duration(seconds: 2)))
          .markUploaded(at: now.add(const Duration(seconds: 3)));
  final version = MemoryVersion.draft(
    id: 'version-original',
    memoryId: 'memory-sunny-window',
    createdByAccountId: 'account-e2e',
    versionNumber: 1,
    title: controller.title.value,
    caption: controller.caption.value,
    memoryDate: controller.memoryDate.value,
    today: now,
    createdAt: now,
    media: <MemoryMedia>[media],
  );
  return MemoryAggregate.draft(
        id: 'memory-sunny-window',
        creatorAccountId: 'account-e2e',
        petIds: const <String>{'pet-mochi', 'pet-luna'},
        workingVersion: version,
        createdAt: now,
      )
      .beginPublishing(now.add(const Duration(minutes: 4)))
      .publish(now.add(const Duration(minutes: 5)));
}

MemoryAggregate _promoteEditDraft(MemoryAggregate memory, DateTime now) {
  final media =
      MemoryMedia.create(
            id: 'media-edited',
            memoryVersionId: 'version-edited',
            sourcePath: '/private/sunny-window-edited.jpg',
            type: MemoryMediaType.image,
            sortOrder: 0,
            isCover: true,
            createdAt: now.add(const Duration(minutes: 6)),
          )
          .queue(now.add(const Duration(minutes: 6, seconds: 1)))
          .startUpload(now.add(const Duration(minutes: 6, seconds: 2)))
          .markUploaded(at: now.add(const Duration(minutes: 6, seconds: 3)));
  final editDraft = MemoryVersion.draft(
    id: 'version-edited',
    memoryId: memory.id,
    createdByAccountId: 'account-e2e',
    versionNumber: 2,
    state: MemoryVersionState.editDraft,
    baseVersionId: memory.currentPublishedVersion!.id,
    title: 'Sunny window nap — edited',
    caption: 'A brighter caption after editing.',
    memoryDate: now,
    today: now,
    createdAt: now.add(const Duration(minutes: 6)),
    media: <MemoryMedia>[media],
  );
  return memory
      .beginEditDraft(
        editDraft: editDraft,
        at: now.add(const Duration(minutes: 6)),
      )
      .promoteEditDraft(now.add(const Duration(minutes: 7)));
}

class _E2eMediaPicker implements MemoryMediaPicker {
  const _E2eMediaPicker();

  @override
  Future<List<MemoryMediaCandidate>> pickImages({required int maxCount}) async {
    return const <MemoryMediaCandidate>[
      MemoryMediaCandidate(
        id: 'local-e2e-image',
        sourcePath: '/private/local-e2e-image.jpg',
        type: MemoryMediaType.image,
        mimeType: 'image/jpeg',
        byteSize: 1024,
      ),
    ];
  }

  @override
  Future<MemoryMediaCandidate?> pickVideo({
    required Duration maxDuration,
  }) async => null;
}
