import 'package:flutter/widgets.dart';

import '../../core/config/app_config.dart';
import '../../features/account_access/data/repositories/in_memory_account_repository.dart';
import '../../features/account_access/domain/entities/account_identity.dart';
import '../../features/account_access/domain/entities/account_session.dart';
import '../../features/account_access/domain/repositories/account_repository.dart';
import '../../features/app_preferences/presentation/app_locale_controller.dart';
import '../../features/app_shell/data/repositories/fake_app_readiness_repository.dart';
import '../../features/app_shell/domain/entities/app_readiness.dart';
import '../../features/app_shell/domain/repositories/app_readiness_repository.dart';
import '../../features/memory_authoring/data/in_memory_memory_lifecycle_repository.dart';
import '../../features/memory_authoring/domain/repositories/memory_lifecycle_repository.dart';
import '../../features/pet_profiles/data/repositories/in_memory_pet_onboarding_draft_repository.dart';
import '../../features/pet_profiles/data/repositories/in_memory_pet_profile_repository.dart';
import '../../features/pet_profiles/domain/repositories/pet_onboarding_draft_repository.dart';
import '../../features/pet_profiles/domain/repositories/pet_profile_repository.dart';
import '../../features/pet_profiles/presentation/controllers/pet_home_controller.dart';
import '../../features/pet_profiles/presentation/controllers/pet_onboarding_controller.dart';
import '../../features/timeline/data/in_memory_timeline_repository.dart';
import '../../features/timeline/domain/repositories/timeline_repository.dart';
import '../app.dart';

class AppBootstrap {
  const AppBootstrap._({
    required this.config,
    required this.readinessRepository,
    required this.accountRepository,
    required this.onboardingDraftRepository,
    required this.onPetOnboardingConfirm,
    required this.petProfileRepository,
    required this.memoryLifecycleRepository,
    required this.timelineRepository,
    required this.petProfilePhotoPicker,
    this.locale,
    this.localeController,
  });

  factory AppBootstrap.demo({
    required AppConfig config,
    required String accountEmailDigest,
    required String accountPasswordDigest,
    Locale? locale,
    AppLocaleController? localeController,
  }) {
    final accountRepository = InMemoryAccountRepository(now: DateTime.now)
      ..seedVerifiedAccountWithDigests(
        id: 'demo-verified-account',
        emailDigest: accountEmailDigest,
        passwordDigest: accountPasswordDigest,
      );
    return AppBootstrap.fake(
      config: config,
      accountRepository: accountRepository,
      locale: locale,
      localeController: localeController,
    );
  }

  factory AppBootstrap.fake({
    required AppConfig config,
    AppReadiness readiness = const AppReadiness(
      isAuthenticated: false,
      petCount: 0,
      pendingDraftCount: 0,
    ),
    Object? loadError,
    Duration loadDelay = Duration.zero,
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
  }) {
    final resolvedAccountRepository =
        accountRepository ?? InMemoryAccountRepository(now: DateTime.now);
    if (accountRepository == null &&
        readiness.isAuthenticated &&
        resolvedAccountRepository is InMemoryAccountRepository) {
      final startedAt = DateTime.now().toUtc();
      resolvedAccountRepository.seedSession(
        AccountSession(
          account: const AccountIdentity(
            id: 'fake-verified-account',
            email: 'fake@pawlum.test',
            isEmailVerified: true,
            authMethods: <AccountAuthMethod>{AccountAuthMethod.emailPassword},
          ),
          startedAt: startedAt,
          expiresAt: startedAt.add(const Duration(hours: 1)),
        ),
      );
    }
    return AppBootstrap._(
      config: config,
      readinessRepository: FakeAppReadinessRepository(
        readiness: readiness,
        loadError: loadError,
        loadDelay: loadDelay,
      ),
      accountRepository: resolvedAccountRepository,
      onboardingDraftRepository:
          onboardingDraftRepository ?? InMemoryPetOnboardingDraftRepository(),
      onPetOnboardingConfirm: onPetOnboardingConfirm ?? (_) async {},
      petProfileRepository:
          petProfileRepository ?? InMemoryPetProfileRepository(),
      memoryLifecycleRepository:
          memoryLifecycleRepository ?? InMemoryMemoryLifecycleRepository(),
      timelineRepository: timelineRepository ?? InMemoryTimelineRepository(),
      petProfilePhotoPicker: petProfilePhotoPicker,
      locale: locale,
      localeController: localeController,
    );
  }

  final AppConfig config;
  final AppReadinessRepository readinessRepository;
  final AccountRepository accountRepository;
  final PetOnboardingDraftRepository onboardingDraftRepository;
  final PetOnboardingConfirmation onPetOnboardingConfirm;
  final PetProfileRepository petProfileRepository;
  final MemoryLifecycleRepository memoryLifecycleRepository;
  final TimelineRepository timelineRepository;
  final PetProfilePhotoPicker petProfilePhotoPicker;
  final Locale? locale;
  final AppLocaleController? localeController;

  Widget createApp() {
    return PawlumApp(
      config: config,
      readinessRepository: readinessRepository,
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
  }
}
