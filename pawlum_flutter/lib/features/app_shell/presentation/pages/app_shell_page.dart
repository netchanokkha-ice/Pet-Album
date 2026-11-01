import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/pawlum_tokens.dart';
import '../../../../core/widgets/pawlum_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app_preferences/presentation/settings_page.dart';
import '../../../memory_authoring/presentation/pages/memory_authoring_page.dart';
import '../../../pet_profiles/presentation/pages/pet_home_view.dart';
import '../../../pet_profiles/presentation/pages/pet_recently_deleted_view.dart';
import '../../../timeline/presentation/pages/memory_detail_view.dart';
import '../../../timeline/presentation/pages/timeline_view.dart';
import '../controllers/app_shell_controller.dart';

class AppShellPage extends GetView<AppShellController> {
  const AppShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const _LoadingPage();
      if (controller.errorMessage.value != null) {
        return _ErrorPage(onRetry: controller.load);
      }
      final destination = controller.destination.value;
      final strings = AppLocalizations.of(context);
      final guarded =
          destination == AppShellDestination.signedOut ||
          destination == AppShellDestination.onboarding;
      return Scaffold(
        body: PawlumPaperBackground(child: _DestinationPage(destination)),
        bottomNavigationBar: guarded
            ? null
            : NavigationBar(
                selectedIndex: _navigationIndex(destination),
                onDestinationSelected: (index) =>
                    controller.open(_navigationDestination(index)),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    label: strings.nav_home,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: strings.nav_add,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: strings.nav_timeline,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    label: strings.nav_settings,
                  ),
                ],
              ),
      );
    });
  }

  int _navigationIndex(AppShellDestination value) => switch (value) {
    AppShellDestination.authoring => 1,
    AppShellDestination.timeline || AppShellDestination.memoryDetail => 2,
    AppShellDestination.settings || AppShellDestination.recentlyDeleted => 3,
    _ => 0,
  };

  AppShellDestination _navigationDestination(int index) => switch (index) {
    1 => AppShellDestination.authoring,
    2 => AppShellDestination.timeline,
    3 => AppShellDestination.settings,
    _ => AppShellDestination.home,
  };
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: PawlumPaperBackground(
      child: Center(
        child: PawlumSkeleton(
          width: 240,
          height: 24,
          semanticLabel: AppLocalizations.of(context).a11y_loading_app,
        ),
      ),
    ),
  );
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: PawlumPaperBackground(
        child: _MessagePage(
          icon: Icons.cloud_off_rounded,
          title: strings.journal_unavailable_title,
          message: strings.journal_unavailable_body,
          action: PawlumPrimaryButton(
            label: strings.action_retry,
            onPressed: onRetry,
          ),
        ),
      ),
    );
  }
}

class _DestinationPage extends GetView<AppShellController> {
  const _DestinationPage(this.destination);
  final AppShellDestination destination;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return switch (destination) {
      AppShellDestination.signedOut => _MessagePage(
        icon: Icons.lock_outline_rounded,
        title: strings.signed_out_title,
        message: (controller.readiness.value?.pendingDraftCount ?? 0) > 0
            ? strings.signed_out_draft_safe
            : strings.signed_out_body,
        action: PawlumPrimaryButton(
          label: strings.sign_in_action,
          onPressed: () => Get.toNamed<void>('/account'),
        ),
      ),
      AppShellDestination.onboarding => _MessagePage(
        icon: Icons.pets_rounded,
        title: strings.onboarding_welcome_title,
        message: strings.onboarding_welcome_body,
        action: PawlumPrimaryButton(
          label: strings.onboarding_create_pet,
          onPressed: () => Get.toNamed<void>(AppRoutes.onboarding),
        ),
      ),
      AppShellDestination.home => const PetHomeView(),
      AppShellDestination.authoring => const MemoryAuthoringPage(),
      AppShellDestination.timeline => const TimelineView(),
      AppShellDestination.memoryDetail => const MemoryDetailView(),
      AppShellDestination.recentlyDeleted => PetRecentlyDeletedView(
        onBack: () => controller.open(AppShellDestination.settings),
      ),
      AppShellDestination.settings => const SettingsPage(),
    };
  }
}

class _MessagePage extends StatelessWidget {
  const _MessagePage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PawlumPetPlaceholder(semanticLabel: title, icon: icon, size: 88),
          const SizedBox(height: PawlumSpacing.lg),
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: PawlumSpacing.xs),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: PawlumSpacing.lg),
            action!,
          ],
        ],
      ),
    ),
  );
}
