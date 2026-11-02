import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/config/app_config.dart';
import '../core/theme/pawlum_theme.dart';
import '../core/theme/pawlum_tokens.dart';
import '../features/account_access/domain/repositories/account_repository.dart';
import '../features/app_preferences/presentation/app_locale_controller.dart';
import '../features/app_shell/domain/repositories/app_readiness_repository.dart';
import '../features/memory_authoring/domain/repositories/memory_lifecycle_repository.dart';
import '../features/pet_profiles/domain/repositories/pet_onboarding_draft_repository.dart';
import '../features/pet_profiles/domain/repositories/pet_profile_repository.dart';
import '../features/pet_profiles/presentation/controllers/pet_home_controller.dart';
import '../features/pet_profiles/presentation/controllers/pet_onboarding_controller.dart';
import '../features/timeline/domain/repositories/timeline_repository.dart';
import '../l10n/app_localizations.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_routes.dart';

class PawlumApp extends StatelessWidget {
  const PawlumApp({
    required this.config,
    required this.readinessRepository,
    required this.accountRepository,
    required this.onboardingDraftRepository,
    required this.onPetOnboardingConfirm,
    required this.petProfileRepository,
    required this.memoryLifecycleRepository,
    required this.timelineRepository,
    required this.petProfilePhotoPicker,
    required this.onboardingPhotoPicker,
    this.locale,
    this.localeController,
    super.key,
  });

  final AppConfig config;
  final AppReadinessRepository readinessRepository;
  final AccountRepository accountRepository;
  final PetOnboardingDraftRepository onboardingDraftRepository;
  final PetOnboardingConfirmation onPetOnboardingConfirm;
  final PetProfileRepository petProfileRepository;
  final MemoryLifecycleRepository memoryLifecycleRepository;
  final TimelineRepository timelineRepository;
  final PetProfilePhotoPicker petProfilePhotoPicker;
  final PetPhotoPicker onboardingPhotoPicker;
  final Locale? locale;
  final AppLocaleController? localeController;

  @override
  Widget build(BuildContext context) {
    final controller = localeController;
    if (controller != null) {
      return ListenableBuilder(
        listenable: controller,
        builder: (context, _) => _buildApp(controller.locale),
      );
    }
    return _buildApp(locale);
  }

  Widget _buildApp(Locale? resolvedLocale) {
    return GetMaterialApp(
      key: ValueKey<String>(resolvedLocale?.languageCode ?? 'system'),
      title: 'Pawlum',
      debugShowCheckedModeBanner: config.isDevelopment,
      initialRoute: AppRoutes.shell,
      initialBinding: InitialBinding(
        readinessRepository,
        accountRepository,
        onboardingDraftRepository,
        onPetOnboardingConfirm,
        petProfileRepository,
        memoryLifecycleRepository,
        timelineRepository,
        petProfilePhotoPicker,
        onboardingPhotoPicker,
        config,
        localeController,
      ),
      getPages: AppRoutes.pages,
      locale: resolvedLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: PawlumTheme.lightForWidth(PawlumBreakpoints.compactMax - 1),
      builder: (context, child) {
        final width = MediaQuery.sizeOf(context).width;

        return Theme(
          data: PawlumTheme.lightForWidth(width),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
