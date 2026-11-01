import 'package:get/get.dart';

import '../../features/account_access/presentation/pages/account_access_page.dart';
import '../../features/app_shell/presentation/pages/app_shell_page.dart';
import '../../features/pet_profiles/presentation/pages/pet_onboarding_page.dart';

abstract final class AppRoutes {
  static const shell = '/';
  static const account = '/account';
  static const onboarding = '/onboarding';

  static final pages = <GetPage<void>>[
    GetPage<void>(name: shell, page: AppShellPage.new),
    GetPage<void>(name: account, page: AccountAccessPage.new),
    GetPage<void>(name: onboarding, page: PetOnboardingPage.new),
  ];
}
