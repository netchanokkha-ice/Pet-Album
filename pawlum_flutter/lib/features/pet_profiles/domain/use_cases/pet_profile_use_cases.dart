import '../entities/pet_models.dart';
import '../repositories/pet_profile_repository.dart';

class CreatePetJournal {
  const CreatePetJournal(this._repository, {required this.today});

  final PetProfileRepository _repository;
  final DateTime Function() today;

  Future<InitializedPetJournal> call(
    InitializePetJournalCommand command,
  ) async {
    final issues = command.input.validate(today());
    if (issues.isNotEmpty) {
      throw PetOnboardingValidationFailure(issues);
    }
    return _repository.initializePetJournal(command);
  }
}

class ListActivePets {
  const ListActivePets(this._repository);

  final PetProfileRepository _repository;

  Future<List<PetProfile>> call(String accountId) {
    return _repository.listActivePets(accountId);
  }
}

class UpdatePetProfile {
  const UpdatePetProfile(this._repository);

  final PetProfileRepository _repository;

  Future<PetProfile> call({
    required String accountId,
    required String petId,
    required String name,
    required DateTime updatedAt,
    String? profileImagePath,
    PetType? requestedType,
  }) {
    return _repository.updateProfile(
      accountId: accountId,
      petId: petId,
      name: name,
      updatedAt: updatedAt,
      profileImagePath: profileImagePath,
      requestedType: requestedType,
    );
  }
}

class ListRecoverableDeletedPets {
  const ListRecoverableDeletedPets(this._repository);

  final PetProfileRepository _repository;

  Future<List<PetProfile>> call({
    required String accountId,
    required DateTime at,
  }) {
    return _repository.listRecoverableDeletedPets(accountId: accountId, at: at);
  }
}

class SoftDeletePet {
  const SoftDeletePet(this._repository);

  final PetProfileRepository _repository;

  Future<PetProfile> call({
    required String accountId,
    required String petId,
    required DateTime deletedAt,
  }) {
    return _repository.softDeletePet(
      accountId: accountId,
      petId: petId,
      deletedAt: deletedAt,
    );
  }
}

class RestorePet {
  const RestorePet(this._repository);

  final PetProfileRepository _repository;

  Future<PetProfile> call({
    required String accountId,
    required String petId,
    required DateTime restoredAt,
  }) {
    return _repository.restorePet(
      accountId: accountId,
      petId: petId,
      restoredAt: restoredAt,
    );
  }
}
