import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../account_access/domain/entities/account_identity.dart';
import '../../account_access/domain/entities/account_session.dart';
import '../../account_access/domain/failures/account_failure.dart';
import '../../account_access/domain/repositories/account_repository.dart';
import '../domain/app_language.dart';
import 'app_locale_controller.dart';

class SettingsController extends GetxController {
  SettingsController(
    this._accountRepository, {
    required this.onOpenRecentlyDeleted,
    required this.onSignedOut,
    this.localeController,
  });

  final AccountRepository _accountRepository;
  final AppLocaleController? localeController;
  final VoidCallback onOpenRecentlyDeleted;
  final Future<void> Function() onSignedOut;

  final isLoading = true.obs;
  final isSavingLanguage = false.obs;
  final isRequestingPassword = false.obs;
  final isSigningOut = false.obs;
  final account = Rxn<AccountIdentity>();
  final error = Rxn<SettingsError>();
  final passwordEmailSent = false.obs;
  final selectedLanguage = AppLanguage.thai.obs;

  AppLanguage get language => selectedLanguage.value;

  bool get supportsPasswordAction =>
      account.value?.authMethods.contains(AccountAuthMethod.emailPassword) ??
      false;

  @override
  void onInit() {
    super.onInit();
    selectedLanguage.value =
        localeController?.language ??
        AppLanguage.tryParse(Get.locale?.languageCode) ??
        AppLanguage.thai;
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    final result = await _accountRepository.restoreSession();
    switch (result) {
      case AccountSuccess<AccountSession?>(value: final session):
        account.value = session?.account;
        if (session == null) error.value = const SettingsError.load();
      case AccountRejected<AccountSession?>():
        error.value = const SettingsError.load();
    }
    isLoading.value = false;
  }

  Future<void> changeLanguage(AppLanguage language) async {
    if (language == this.language) return;
    isSavingLanguage.value = true;
    error.value = null;
    try {
      final controller = localeController;
      if (controller == null) {
        await Get.updateLocale(language.locale);
      } else {
        await controller.setLanguage(language);
      }
      selectedLanguage.value = language;
    } on Object {
      error.value = const SettingsError.saveLanguage();
    } finally {
      isSavingLanguage.value = false;
    }
  }

  Future<void> requestPasswordChange() async {
    final identity = account.value;
    if (identity == null || !supportsPasswordAction) return;
    isRequestingPassword.value = true;
    error.value = null;
    passwordEmailSent.value = false;
    final result = await _accountRepository.requestPasswordRecovery(
      email: identity.email,
    );
    switch (result) {
      case AccountSuccess():
        passwordEmailSent.value = true;
      case AccountRejected(failure: final failure):
        error.value = SettingsError.account(failure);
    }
    isRequestingPassword.value = false;
  }

  Future<void> signOut() async {
    isSigningOut.value = true;
    error.value = null;
    final result = await _accountRepository.signOut();
    switch (result) {
      case AccountSuccess():
        localeController?.detachAccount();
        await onSignedOut();
      case AccountRejected():
        error.value = const SettingsError.signOut();
    }
    isSigningOut.value = false;
  }
}

enum SettingsErrorType { load, saveLanguage, signOut, account }

class SettingsError {
  const SettingsError._(this.type, [this.accountFailure]);

  const SettingsError.load() : this._(SettingsErrorType.load);
  const SettingsError.saveLanguage() : this._(SettingsErrorType.saveLanguage);
  const SettingsError.signOut() : this._(SettingsErrorType.signOut);
  const SettingsError.account(AccountFailure failure)
    : this._(SettingsErrorType.account, failure);

  final SettingsErrorType type;
  final AccountFailure? accountFailure;
}
