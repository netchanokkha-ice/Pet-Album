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
  Future<PetPhotoSelection?> pickPhoto();
}

class NoopPetPhotoPicker implements PetPhotoPicker {
  const NoopPetPhotoPicker();

  @override
  Future<PetPhotoSelection?> pickPhoto() async => null;
}

typedef PetOnboardingExit = Future<void> Function();
typedef PetOnboardingConfirmation =
    Future<void> Function(PetOnboardingDraft draft);

String _defaultDraftIdGenerator() => 'active';

class PetOnboardingController extends GetxController {
  PetOnboardingController(
    this._draftRepository,
    this._accountRepository, {
    required this.now,
    required this.onExit,
    required this.onConfirm,
    this.photoPicker = const NoopPetPhotoPicker(),
    this.draftIdGenerator = _defaultDraftIdGenerator,
  });

  final PetOnboardingDraftRepository _draftRepository;
  final AccountRepository _accountRepository;
  final DateTime Function() now;
  final PetOnboardingExit onExit;
  final PetOnboardingConfirmation onConfirm;
  final PetPhotoPicker photoPicker;
  final String Function() draftIdGenerator;

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final draft = Rxn<PetOnboardingDraft>();
  final issues = <PetOnboardingIssue>{}.obs;
  final isTurningForward = true.obs;
  final nameController = TextEditingController();
  final otherTypeController = TextEditingController();
  Future<void> _saveTail = Future<void>.value();

  PetOnboardingStep get step => draft.value?.step ?? PetOnboardingStep.welcome;
  PetOnboardingQuestion get question =>
      draft.value?.resolvedQuestion ?? PetOnboardingQuestion.welcome;

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
          id: draftIdGenerator(),
          step: PetOnboardingStep.welcome,
          updatedAt: now(),
        );
    draft.value = resolved;
    _syncTextControllers(resolved);
    isLoading.value = false;
  }

  Future<void> begin() => _moveTo(PetOnboardingQuestion.name);

  Future<void> updateName(String value) {
    if (value.trim().isNotEmpty) {
      issues.remove(PetOnboardingIssue.nameRequired);
    }
    return _update((PetOnboardingDraft current) {
      return current.copyWith(name: value, updatedAt: now());
    });
  }

  Future<void> selectType(PetType type) {
    issues.remove(PetOnboardingIssue.typeRequired);
    issues.remove(PetOnboardingIssue.otherTypeLabelRequired);
    return _update((PetOnboardingDraft current) {
      return current.copyWith(
        type: type,
        clearCustomTypeLabel: type != PetType.other,
        updatedAt: now(),
      );
    });
  }

  Future<void> updateOtherType(String value) {
    if (value.trim().isNotEmpty) {
      issues.remove(PetOnboardingIssue.otherTypeLabelRequired);
    }
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

  Future<bool> continueFromName() async {
    final current = draft.value;
    if (current == null) return false;
    if (current.name.trim().isEmpty) {
      issues.assignAll(<PetOnboardingIssue>{PetOnboardingIssue.nameRequired});
      return false;
    }
    await _moveTo(PetOnboardingQuestion.type);
    return true;
  }

  Future<bool> continueFromType() async {
    final current = draft.value;
    if (current == null) return false;
    if (current.type == null) {
      issues.assignAll(<PetOnboardingIssue>{PetOnboardingIssue.typeRequired});
      return false;
    }
    await _moveTo(
      current.type == PetType.other
          ? PetOnboardingQuestion.customType
          : PetOnboardingQuestion.birthday,
    );
    return true;
  }

  Future<bool> continueFromCustomType() async {
    final current = draft.value;
    if (current == null) return false;
    if (current.customTypeLabel?.trim().isEmpty ?? true) {
      issues.assignAll(<PetOnboardingIssue>{
        PetOnboardingIssue.otherTypeLabelRequired,
      });
      return false;
    }
    await _moveTo(PetOnboardingQuestion.birthday);
    return true;
  }

  Future<void> continueFromBirthday() =>
      _moveTo(PetOnboardingQuestion.firstMetDate);

  Future<void> continueFromFirstMetDate() =>
      _moveTo(PetOnboardingQuestion.photo);

  Future<void> pickPhoto() async {
    final selected = await photoPicker.pickPhoto();
    if (selected == null) return;
    await _update((PetOnboardingDraft current) {
      return current.copyWith(
        profileImageBytes: selected.bytes,
        profileImageFileName: selected.fileName,
        profileImageMimeType: selected.mimeType,
        clearProfileImagePath: true,
        updatedAt: now(),
      );
    });
  }

  Future<void> continueFromPhoto() =>
      _moveTo(PetOnboardingQuestion.confirmation);

  Future<void> back() {
    final previous = switch (question) {
      PetOnboardingQuestion.welcome => PetOnboardingQuestion.welcome,
      PetOnboardingQuestion.name => PetOnboardingQuestion.welcome,
      PetOnboardingQuestion.type => PetOnboardingQuestion.name,
      PetOnboardingQuestion.customType => PetOnboardingQuestion.type,
      PetOnboardingQuestion.birthday =>
        draft.value?.type == PetType.other
            ? PetOnboardingQuestion.customType
            : PetOnboardingQuestion.type,
      PetOnboardingQuestion.firstMetDate => PetOnboardingQuestion.birthday,
      PetOnboardingQuestion.photo => PetOnboardingQuestion.firstMetDate,
      PetOnboardingQuestion.confirmation => PetOnboardingQuestion.photo,
    };
    return _moveTo(previous, forward: false);
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

  Future<void> _moveTo(PetOnboardingQuestion next, {bool forward = true}) {
    isTurningForward.value = forward;
    issues.clear();
    return _update((PetOnboardingDraft current) {
      return current.copyWith(
        step: _stepFor(next),
        question: next,
        updatedAt: now(),
      );
    });
  }

  PetOnboardingStep _stepFor(PetOnboardingQuestion question) {
    return switch (question) {
      PetOnboardingQuestion.welcome => PetOnboardingStep.welcome,
      PetOnboardingQuestion.name ||
      PetOnboardingQuestion.type ||
      PetOnboardingQuestion.customType ||
      PetOnboardingQuestion.birthday ||
      PetOnboardingQuestion.firstMetDate => PetOnboardingStep.petInfo,
      PetOnboardingQuestion.photo => PetOnboardingStep.photo,
      PetOnboardingQuestion.confirmation => PetOnboardingStep.confirmation,
    };
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
