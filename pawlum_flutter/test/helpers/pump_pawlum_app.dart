import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/app/bootstrap/app_bootstrap.dart';
import 'package:pawlum/core/config/app_config.dart';
import 'package:pawlum/features/account_access/domain/repositories/account_repository.dart';
import 'package:pawlum/features/app_preferences/presentation/app_locale_controller.dart';
import 'package:pawlum/features/app_shell/domain/entities/app_readiness.dart';
import 'package:pawlum/features/memory_authoring/domain/repositories/memory_lifecycle_repository.dart';
import 'package:pawlum/features/pet_profiles/domain/repositories/pet_onboarding_draft_repository.dart';
import 'package:pawlum/features/pet_profiles/domain/repositories/pet_profile_repository.dart';
import 'package:pawlum/features/pet_profiles/presentation/controllers/pet_home_controller.dart';
import 'package:pawlum/features/pet_profiles/presentation/controllers/pet_onboarding_controller.dart';
import 'package:pawlum/features/timeline/domain/repositories/timeline_repository.dart';

extension PumpPawlumApp on WidgetTester {
  Future<void> pumpPawlumApp({
    AppConfig? config,
    AppReadiness readiness = const AppReadiness(
      isAuthenticated: false,
      petCount: 0,
      pendingDraftCount: 0,
    ),
    Object? loadError,
    Duration loadDelay = Duration.zero,
    bool settle = true,
    AccountRepository? accountRepository,
    PetOnboardingDraftRepository? onboardingDraftRepository,
    PetOnboardingConfirmation? onPetOnboardingConfirm,
    PetProfileRepository? petProfileRepository,
    MemoryLifecycleRepository? memoryLifecycleRepository,
    TimelineRepository? timelineRepository,
    PetProfilePhotoPicker petProfilePhotoPicker =
        const NoopPetProfilePhotoPicker(),
    Locale? locale,
    AppLocaleController? localeController,
  }) async {
    final bootstrap = AppBootstrap.fake(
      config: config ?? AppConfig.test(),
      readiness: readiness,
      loadError: loadError,
      loadDelay: loadDelay,
      accountRepository: accountRepository,
      onboardingDraftRepository: onboardingDraftRepository,
      onPetOnboardingConfirm: onPetOnboardingConfirm,
      petProfileRepository: petProfileRepository,
      memoryLifecycleRepository: memoryLifecycleRepository,
      timelineRepository: timelineRepository,
      petProfilePhotoPicker: petProfilePhotoPicker,
      locale: locale,
      localeController: localeController,
    );

    await pumpWidget(bootstrap.createApp());
    if (settle) await pumpAndSettle();
  }
}
