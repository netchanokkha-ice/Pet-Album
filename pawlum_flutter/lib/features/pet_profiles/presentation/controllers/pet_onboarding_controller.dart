import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../account_access/domain/entities/account_session.dart';
import '../../../account_access/domain/failures/account_failure.dart';
import '../../../account_access/domain/repositories/account_repository.dart';
import '../../domain/entities/pet_models.dart';
import '../../domain/entities/pet_onboarding_draft.dart';
import '../../domain/repositories/pet_onboarding_draft_repository.dart';

abstract interface class PetPhotoPicker {
  Future<String?> pickPhoto();
}

class NoopPetPhotoPicker implements PetPhotoPicker {
  const NoopPetPhotoPicker();

  @override
  Future<String?> pickPhoto() async => null;
}

typedef PetOnboardingExit = Future<void> Function();
typedef PetOnboardingConfirmation =
    Future<void> Function(PetOnboardingDraft draft);

class PetOnboardingController extends GetxController {
  PetOnboardingController(
    this._draftRepository,
    this._accountRepository, {
    required this.now,
    required this.onExit,
    required this.onConfirm,
    this.photoPicker = const NoopPetPhotoPicker(),
  });

  final PetOnboardingDraftRepository _draftRepository;
  final AccountRepository _accountRepository;
  final DateTime Function() now;
  final PetOnboardingExit onExit;
  final PetOnboardingConfirmation onConfirm;
  final PetPhotoPicker photoPicker;

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final draft = Rxn<PetOnboardingDraft>();
  final issues = <PetOnboardingIssue>{}.obs;
  final nameController = TextEditingController();
  final otherTypeController = TextEditingController();
  Future<void> _saveTail = Future<void>.value();

  PetOnboardingStep get step => draft.value?.step ?? PetOnboardingStep.welcome;

  @override
  void onReady() {
    super.onReady();
    unawaited(initialize());
  }

  @override
  void onClose() {
    nameController.dispose();
    otherTypeController.dispose();
    super.onClose();
  }

  Future<void> initialize() async {
    isLoading.value = true;
    errorMessage.value = null;
    final sessionResult = await _accountRepository.restoreSession();
    final session = switch (sessionResult) {
      AccountSuccess<AccountSession?>(value: final value) => value,
      _ => null,
    };
    if (session == null) {
      errorMessage.value = 'Sign in again to continue pet setup.';
      isLoading.value = false;
      return;
    }
    final restored = await _draftRepository.load(session.account.id);
    final resolved =
        restored ??
        PetOnboardingDraft(
          accountId: session.account.id,
          id: 'active',
          step: PetOnboardingStep.welcome,
          updatedAt: now(),
        );
    draft.value = resolved;
    _syncTextControllers(resolved);
    isLoading.value = false;
  }

  Future<void> begin() => _moveTo(PetOnboardingStep.petInfo);

  Future<void> updateName(String value) {
    return _update((PetOnboardingDraft current) {
      return current.copyWith(name: value, updatedAt: now());
    });
  }

  Future<void> selectType(PetType type) {
    issues.remove(PetOnboardingIssue.typeRequired);
    return _update((PetOnboardingDraft current) {
      return current.copyWith(
        type: type,
        clearCustomTypeLabel: type != PetType.other,
        updatedAt: now(),
      );
    });
  }

  Future<void> updateOtherType(String value) {
    return _update((PetOnboardingDraft current) {
      return current.copyWith(customTypeLabel: value, updatedAt: now());
    });
  }

  Future<void> setBirthday(DateTime? value) {
    return _update((PetOnboardingDraft current) {
      return current.copyWith(
        birthday: value,
        clearBirthday: value == null,
        updatedAt: now(),
      );
    });
  }

  Future<void> setFirstMetDate(DateTime? value) {
    return _update((PetOnboardingDraft current) {
      return current.copyWith(
        firstMetDate: value,
        clearFirstMetDate: value == null,
        updatedAt: now(),
      );
    });
  }

  Future<bool> continueFromPetInfo() async {
    final current = draft.value;
    if (current == null) return false;
    final validationIssues = current.input.validate(now()).toSet();
    issues.assignAll(validationIssues);
    if (validationIssues.isNotEmpty) return false;
    await _moveTo(PetOnboardingStep.photo);
    return true;
  }

  Future<void> pickPhoto() async {
    final selectedPath = await photoPicker.pickPhoto();
    if (selectedPath == null) return;
    await _update((PetOnboardingDraft current) {
      return current.copyWith(profileImagePath: selectedPath, updatedAt: now());
    });
  }

  Future<void> continueFromPhoto() => _moveTo(PetOnboardingStep.confirmation);

  Future<void> back() {
    final previous = switch (step) {
      PetOnboardingStep.welcome => PetOnboardingStep.welcome,
      PetOnboardingStep.petInfo => PetOnboardingStep.welcome,
      PetOnboardingStep.photo => PetOnboardingStep.petInfo,
      PetOnboardingStep.confirmation => PetOnboardingStep.photo,
    };
    return _moveTo(previous);
  }

  Future<void> keepDraftAndExit() async {
    await _saveTail;
    await onExit();
  }

  Future<void> discardAndExit() async {
    final current = draft.value;
    if (current != null) await _draftRepository.clear(current.accountId);
    await onExit();
  }

  Future<void> confirm() async {
    final current = draft.value;
    if (current == null) return;
    isSaving.value = true;
    try {
      await _persist(current.copyWith(updatedAt: now()));
      await onConfirm(current);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _moveTo(PetOnboardingStep next) {
    issues.clear();
    return _update((PetOnboardingDraft current) {
      return current.copyWith(step: next, updatedAt: now());
    });
  }

  Future<void> _update(
    PetOnboardingDraft Function(PetOnboardingDraft current) change,
  ) async {
    final current = draft.value;
    if (current == null) return;
    final updated = change(current);
    draft.value = updated;
    await _persist(updated);
  }

  Future<void> _persist(PetOnboardingDraft value) {
    _saveTail = _saveTail.then((_) => _draftRepository.save(value));
    return _saveTail;
  }

  void _syncTextControllers(PetOnboardingDraft value) {
    nameController.text = value.name;
    otherTypeController.text = value.customTypeLabel ?? '';
  }
}
