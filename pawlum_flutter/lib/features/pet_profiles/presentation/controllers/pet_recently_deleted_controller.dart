import 'dart:async';

import 'package:get/get.dart';

import '../../../account_access/domain/entities/account_session.dart';
import '../../../account_access/domain/failures/account_failure.dart';
import '../../../account_access/domain/repositories/account_repository.dart';
import '../../domain/entities/pet_models.dart';
import '../../domain/repositories/pet_profile_repository.dart';

class PetRecentlyDeletedController extends GetxController {
  PetRecentlyDeletedController(
    this._repository,
    this._accountRepository, {
    required this.now,
    this.onPetRestored,
  });

  final PetProfileRepository _repository;
  final AccountRepository _accountRepository;
  final DateTime Function() now;
  final Future<void> Function()? onPetRestored;

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final pets = <PetProfile>[].obs;
  final restoringPetId = RxnString();
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
      pets.assignAll(
        await _repository.listRecoverableDeletedPets(
          accountId: session.account.id,
          at: now(),
        ),
      );
    } on Object {
      errorMessage.value = 'We could not load Recently Deleted.';
    } finally {
      isLoading.value = false;
    }
  }

  int daysRemaining(PetProfile pet) => pet.recoveryDaysRemaining(now());

  Future<bool> restore(PetProfile pet) async {
    final accountId = _accountId;
    if (accountId == null || restoringPetId.value != null) return false;
    restoringPetId.value = pet.id;
    errorMessage.value = null;
    try {
      await _repository.restorePet(
        accountId: accountId,
        petId: pet.id,
        restoredAt: now(),
      );
      pets.removeWhere((PetProfile item) => item.id == pet.id);
      await onPetRestored?.call();
      return true;
    } on PetDeletionExpiredFailure {
      pets.removeWhere((PetProfile item) => item.id == pet.id);
      errorMessage.value = 'This pet is no longer available to restore.';
      return false;
    } on Object {
      errorMessage.value = 'We could not restore this pet.';
      return false;
    } finally {
      restoringPetId.value = null;
    }
  }
}
