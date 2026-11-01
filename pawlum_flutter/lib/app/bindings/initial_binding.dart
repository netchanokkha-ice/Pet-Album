import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/app_config.dart';
import '../../features/account_access/domain/repositories/account_repository.dart';
import '../../features/account_access/presentation/controllers/account_access_controller.dart';
import '../../features/app_preferences/presentation/app_locale_controller.dart';
import '../../features/app_preferences/presentation/settings_controller.dart';
import '../../features/app_shell/domain/repositories/app_readiness_repository.dart';
import '../../features/app_shell/presentation/controllers/app_shell_controller.dart';
import '../../features/memory_authoring/data/image_picker_memory_media_picker.dart';
import '../../features/memory_authoring/data/in_memory_memory_authoring_draft_repository.dart';
import '../../features/memory_authoring/domain/repositories/memory_authoring_draft_repository.dart';
import '../../features/memory_authoring/domain/repositories/memory_lifecycle_repository.dart';
import '../../features/memory_authoring/presentation/controllers/memory_authoring_controller.dart';
import '../../features/memory_authoring/presentation/controllers/memory_lifecycle_controller.dart';
import '../../features/pet_profiles/domain/repositories/pet_onboarding_draft_repository.dart';
import '../../features/pet_profiles/domain/repositories/pet_profile_repository.dart';
import '../../features/pet_profiles/presentation/controllers/pet_home_controller.dart';
import '../../features/pet_profiles/presentation/controllers/pet_onboarding_controller.dart';
import '../../features/pet_profiles/presentation/controllers/pet_recently_deleted_controller.dart';
import '../../features/timeline/domain/entities/timeline_models.dart';
import '../../features/timeline/domain/repositories/timeline_repository.dart';
import '../../features/timeline/presentation/controllers/memory_detail_controller.dart';
import '../../features/timeline/presentation/controllers/timeline_controller.dart';
import '../routes/app_routes.dart';

class InitialBinding extends Bindings {
  InitialBinding(
    this.readinessRepository,
    this.accountRepository,
    this.onboardingDraftRepository,
    this.onPetOnboardingConfirm,
    this.petProfileRepository,
    this.memoryLifecycleRepository,
    this.timelineRepository,
    this.petProfilePhotoPicker,
    this.config,
    this.localeController,
  );

  final AppReadinessRepository readinessRepository;
  final AccountRepository accountRepository;
  final PetOnboardingDraftRepository onboardingDraftRepository;
  final PetOnboardingConfirmation onPetOnboardingConfirm;
  final PetProfileRepository petProfileRepository;
  final MemoryLifecycleRepository memoryLifecycleRepository;
  final TimelineRepository timelineRepository;
  final PetProfilePhotoPicker petProfilePhotoPicker;
  final AppConfig config;
  final AppLocaleController? localeController;

  @override
  void dependencies() {
    final appLocaleController = localeController;
    if (appLocaleController != null) {
      Get.put<AppLocaleController>(appLocaleController, permanent: true);
    }
    Get.put<AppReadinessRepository>(readinessRepository, permanent: true);
    Get.put<AccountRepository>(accountRepository, permanent: true);
    Get.put<PetOnboardingDraftRepository>(
      onboardingDraftRepository,
      permanent: true,
    );
    Get.put<PetProfileRepository>(petProfileRepository, permanent: true);
    Get.put<MemoryLifecycleRepository>(
      memoryLifecycleRepository,
      permanent: true,
    );
    Get.put<TimelineRepository>(timelineRepository, permanent: true);
    Get.put<MemoryAuthoringDraftRepository>(
      InMemoryMemoryAuthoringDraftRepository(),
      permanent: true,
    );
    Get.lazyPut<AppShellController>(
      () => AppShellController(
        Get.find<AppReadinessRepository>(),
        Get.find<AccountRepository>(),
        now: DateTime.now,
        localeController: localeController,
      ),
    );
    Get.lazyPut<AccountAccessController>(
      () => AccountAccessController(
        Get.find<AccountRepository>(),
        googleOAuthEnabled: config.googleOAuthConfigured,
        oauthRedirectUri: config.oauthRedirectUri,
        onAuthenticated: (_) async {
          await Get.find<AppShellController>().load();
          if (Get.currentRoute == AppRoutes.account) {
            Get.back<void>();
          } else {
            await Get.offAllNamed<void>(AppRoutes.shell);
          }
        },
      ),
      fenix: true,
    );
    Get.lazyPut<SettingsController>(
      () => SettingsController(
        Get.find<AccountRepository>(),
        localeController: localeController,
        onOpenRecentlyDeleted: () {
          Get.find<AppShellController>().open(
            AppShellDestination.recentlyDeleted,
          );
        },
        onSignedOut: () async {
          Get.find<AppShellController>().markSignedOut();
        },
      ),
      fenix: true,
    );
    Get.lazyPut<PetOnboardingController>(
      () => PetOnboardingController(
        Get.find<PetOnboardingDraftRepository>(),
        Get.find<AccountRepository>(),
        now: DateTime.now,
        onExit: () async {
          Get.back<void>();
        },
        onConfirm: onPetOnboardingConfirm,
      ),
      fenix: true,
    );
    Get.lazyPut<PetHomeController>(
      () => PetHomeController(
        Get.find<PetProfileRepository>(),
        Get.find<AccountRepository>(),
        now: DateTime.now,
        photoPicker: petProfilePhotoPicker,
        onAddPet: () async {
          await Get.toNamed<void>(AppRoutes.onboarding);
        },
        onOpenTimeline: (String petId) async {
          final home = Get.find<PetHomeController>();
          final pet = home.pets.firstWhereOrNull((value) => value.id == petId);
          if (pet != null) {
            await Get.find<TimelineController>().selectPet(
              id: pet.id,
              name: pet.name,
              imagePath: pet.profileImagePath,
            );
          }
          Get.find<AppShellController>().open(AppShellDestination.timeline);
        },
        onPetDeleted: () async {
          if (Get.isRegistered<PetRecentlyDeletedController>()) {
            await Get.find<PetRecentlyDeletedController>().load();
          }
        },
      ),
      fenix: true,
    );
    Get.lazyPut<TimelineController>(
      () => TimelineController(
        Get.find<TimelineRepository>(),
        onAddMemory: () async {
          Get.find<AppShellController>().open(AppShellDestination.authoring);
        },
        onOpenMemory: (TimelineEntry entry) async {
          Get.find<MemoryDetailController>().open(entry.memoryId);
          Get.find<AppShellController>().open(AppShellDestination.memoryDetail);
        },
        onResumeDraft: (TimelineEntry entry) async {
          await Get.find<MemoryAuthoringController>().resumeDraft(
            draftId: entry.workingVersionId ?? entry.visibleVersionId,
            memoryId: entry.memoryId,
          );
          Get.find<AppShellController>().open(AppShellDestination.authoring);
        },
      ),
      fenix: true,
    );
    Get.lazyPut<PetRecentlyDeletedController>(
      () => PetRecentlyDeletedController(
        Get.find<PetProfileRepository>(),
        Get.find<AccountRepository>(),
        now: DateTime.now,
        onPetRestored: () async {
          if (Get.isRegistered<PetHomeController>()) {
            await Get.find<PetHomeController>().load();
          }
        },
      ),
      fenix: true,
    );
    Get.lazyPut<MemoryAuthoringController>(
      () => MemoryAuthoringController(
        picker: ImagePickerMemoryMediaPicker(
          ImagePicker(),
          idGenerator: const Uuid().v4,
        ),
        now: DateTime.now,
        draftRepository: Get.find<MemoryAuthoringDraftRepository>(),
        accountId: 'fake-verified-account',
        onExit: () async {
          Get.find<AppShellController>().open(AppShellDestination.home);
        },
      ),
      fenix: true,
    );
    Get.lazyPut<MemoryLifecycleController>(
      () => MemoryLifecycleController(
        Get.find<MemoryLifecycleRepository>(),
        Get.find<AccountRepository>(),
        now: DateTime.now,
        onMemoryHidden: (String memoryId) {
          if (Get.isRegistered<TimelineController>()) {
            Get.find<TimelineController>().hideMemory(memoryId);
          }
          if (Get.isRegistered<MemoryDetailController>()) {
            Get.find<MemoryDetailController>().memoryDeleted(memoryId);
          }
        },
        onMemoryRestored: (String memoryId) {
          if (Get.isRegistered<TimelineController>()) {
            Get.find<TimelineController>().restoreMemory(memoryId);
          }
        },
      ),
      fenix: true,
    );
    Get.lazyPut<MemoryDetailController>(
      () => MemoryDetailController(
        Get.find<MemoryLifecycleController>(),
        onSafeExit: () async {
          Get.find<AppShellController>().open(AppShellDestination.timeline);
        },
        onResumeEdit: (memory) async {
          final working = memory.currentWorkingVersion;
          if (working == null) return;
          await Get.find<MemoryAuthoringController>().resumeDraft(
            draftId: working.id,
            memoryId: memory.id,
          );
          Get.find<AppShellController>().open(AppShellDestination.authoring);
        },
      ),
      fenix: true,
    );
  }
}
