import 'package:get/get.dart';

import '../../../account_access/domain/entities/account_session.dart';
import '../../../account_access/domain/failures/account_failure.dart';
import '../../../account_access/domain/repositories/account_repository.dart';
import '../../../app_preferences/presentation/app_locale_controller.dart';
import '../../domain/entities/app_readiness.dart';
import '../../domain/repositories/app_readiness_repository.dart';

enum AppShellDestination {
  signedOut,
  onboarding,
  home,
  authoring,
  timeline,
  memoryDetail,
  recentlyDeleted,
  settings,
}

class AppShellController extends GetxController {
  AppShellController(
    this._repository,
    this._accountRepository, {
    required this.now,
    this.localeController,
  });

  final AppReadinessRepository _repository;
  final AccountRepository _accountRepository;
  final AppLocaleController? localeController;
  final DateTime Function() now;

  final isLoading = true.obs;
  final readiness = Rxn<AppReadiness>();
  final errorMessage = RxnString();
  final destination = AppShellDestination.home.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final appReadiness = await _repository.load();
      final sessionResult = await _accountRepository.restoreSession();
      final restoredSession = switch (sessionResult) {
        AccountSuccess<AccountSession?>(value: final session) => session,
        _ => null,
      };
      final isAuthenticated = switch (sessionResult) {
        AccountSuccess<AccountSession?>(value: final session) =>
          session?.canAccessJournalAt(now()) ?? false,
        AccountRejected<AccountSession?>(
          failure: AccountFailure(code: AccountFailureCode.sessionExpired),
        ) =>
          false,
        _ => false,
      };
      if (isAuthenticated && restoredSession != null) {
        try {
          await localeController?.attachAccount(restoredSession.account.id);
        } on Object {
          // Remote preference sync must not block access to a local journal.
        }
      }
      readiness.value = AppReadiness(
        isAuthenticated: isAuthenticated,
        petCount: appReadiness.petCount,
        pendingDraftCount: appReadiness.pendingDraftCount,
      );
      final requested = destination.value == AppShellDestination.signedOut
          ? AppShellDestination.home
          : destination.value;
      destination.value = _guard(requested);
    } on Object {
      errorMessage.value = 'We could not prepare your journal.';
    } finally {
      isLoading.value = false;
    }
  }

  void open(AppShellDestination requested) =>
      destination.value = _guard(requested);

  void markSignedOut() {
    final current = readiness.value;
    readiness.value = AppReadiness(
      isAuthenticated: false,
      petCount: current?.petCount ?? 0,
      pendingDraftCount: current?.pendingDraftCount ?? 0,
    );
    destination.value = AppShellDestination.signedOut;
  }

  AppShellDestination _guard(AppShellDestination requested) {
    final state = readiness.value;
    if (state == null || !state.isAuthenticated) {
      return AppShellDestination.signedOut;
    }
    if (state.petCount == 0) {
      return AppShellDestination.onboarding;
    }
    return requested;
  }
}
