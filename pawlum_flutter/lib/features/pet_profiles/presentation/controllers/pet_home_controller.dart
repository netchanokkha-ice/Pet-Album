import 'dart:async';

import 'package:get/get.dart';

import '../../../account_access/domain/entities/account_session.dart';
import '../../../account_access/domain/failures/account_failure.dart';
import '../../../account_access/domain/repositories/account_repository.dart';
import '../../domain/entities/pet_models.dart';
import '../../domain/repositories/pet_profile_repository.dart';

abstract interface class PetProfilePhotoPicker {
  Future<String?> pickPhoto();
}

class NoopPetProfilePhotoPicker implements PetProfilePhotoPicker {
  const NoopPetProfilePhotoPicker();

  @override
  Future<String?> pickPhoto() async => null;
}

class PetHomeController extends GetxController {
  PetHomeController(
    this._repository,
    this._accountRepository, {
    required this.now,
    required this.onAddPet,
    required this.onOpenTimeline,
    this.onPetDeleted,
    this.photoPicker = const NoopPetProfilePhotoPicker(),
  });

  final PetProfileRepository _repository;
  final AccountRepository _accountRepository;
  final DateTime Function() now;
  final Future<void> Function() onAddPet;
  final Future<void> Function(String petId) onOpenTimeline;
  final Future<void> Function()? onPetDeleted;
  final PetProfilePhotoPicker photoPicker;

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final pets = <PetProfile>[].obs;
  final selectedPetId = RxnString();
  String? _accountId;

  @override
  void onReady() {
    super.onReady();
    unawaited(load());
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final sessionResult = await _accountRepository.restoreSession();
      final session = switch (sessionResult) {
        AccountSuccess<AccountSession?>(value: final value) => value,
        _ => null,
      };
      if (session == null) throw StateError('No active account session.');
      _accountId = session.account.id;
      final loaded = await _repository.listActivePets(session.account.id);
      pets.assignAll(loaded);
      if (loaded.isNotEmpty &&
          !loaded.any((PetProfile pet) => pet.id == selectedPetId.value)) {
        selectedPetId.value = loaded.first.id;
      }
    } on Object {
      errorMessage.value = 'We could not load your pet journals.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectPet(PetProfile pet) async {
    selectedPetId.value = pet.id;
    await onOpenTimeline(pet.id);
  }

  Future<void> addPet() => onAddPet();

  Future<String?> choosePhoto() => photoPicker.pickPhoto();

  Future<bool> saveProfile({
    required PetProfile pet,
    required String name,
    required String? profileImagePath,
  }) async {
    final accountId = _accountId;
    if (accountId == null || name.trim().isEmpty) return false;
    try {
      final updated = await _repository.updateProfile(
        accountId: accountId,
        petId: pet.id,
        name: name,
        profileImagePath: profileImagePath,
        requestedType: pet.type,
        updatedAt: now(),
      );
      final index = pets.indexWhere((PetProfile item) => item.id == pet.id);
      if (index >= 0) pets[index] = updated;
      return true;
    } on Object {
      errorMessage.value = 'We could not update this pet profile.';
      return false;
    }
  }

  Future<bool> deletePet(PetProfile pet) async {
    final accountId = _accountId;
    if (accountId == null) return false;
    try {
      await _repository.softDeletePet(
        accountId: accountId,
        petId: pet.id,
        deletedAt: now(),
      );
      pets.removeWhere((PetProfile item) => item.id == pet.id);
      if (selectedPetId.value == pet.id) {
        selectedPetId.value = pets.isEmpty ? null : pets.first.id;
      }
      await onPetDeleted?.call();
      return true;
    } on Object {
      errorMessage.value = 'We could not move this pet to Recently Deleted.';
      return false;
    }
  }
}
