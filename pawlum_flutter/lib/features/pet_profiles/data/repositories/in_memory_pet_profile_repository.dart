import '../../domain/entities/pet_models.dart';
import '../../domain/repositories/pet_profile_repository.dart';

class InMemoryPetProfileRepository implements PetProfileRepository {
  final Map<String, PetProfile> _pets = <String, PetProfile>{};
  final List<PetMembership> _memberships = <PetMembership>[];
  final Map<String, FirstMemoryMilestone> _firstMemories =
      <String, FirstMemoryMilestone>{};

  @override
  Future<InitializedPetJournal> initializePetJournal(
    InitializePetJournalCommand command,
  ) async {
    if (_pets.containsKey(command.petId) ||
        _firstMemories.containsKey(command.firstMemoryId)) {
      throw StateError('Pet initialization identifiers must be unique.');
    }
    final type = command.input.type;
    if (type == null) {
      throw const PetOnboardingValidationFailure(<PetOnboardingIssue>[
        PetOnboardingIssue.typeRequired,
      ]);
    }
    final pet = PetProfile(
      id: command.petId,
      name: command.input.name.trim(),
      type: type,
      customTypeLabel: command.input.customTypeLabel?.trim(),
      profileImagePath: command.input.profileImagePath,
      birthday: command.input.birthday,
      firstMetDate: command.input.firstMetDate,
      createdAt: command.createdAt,
      updatedAt: command.createdAt,
    );
    final membership = PetMembership(
      petId: pet.id,
      accountId: command.accountId,
      createdAt: command.createdAt,
    );
    final firstMemory = FirstMemoryMilestone(
      id: command.firstMemoryId,
      petId: pet.id,
      memoryDate:
          command.input.firstMetDate ??
          command.input.birthday ??
          command.createdAt,
      createdAt: command.createdAt,
    );

    _pets[pet.id] = pet;
    _memberships.add(membership);
    _firstMemories[firstMemory.id] = firstMemory;
    return InitializedPetJournal(
      pet: pet,
      membership: membership,
      firstMemory: firstMemory,
    );
  }

  @override
  Future<List<PetProfile>> listActivePets(String accountId) async {
    final allowedPetIds = _memberships
        .where(
          (PetMembership membership) =>
              membership.accountId == accountId &&
              membership.status == PetMembershipStatus.active,
        )
        .map((PetMembership membership) => membership.petId)
        .toSet();
    return _pets.values
        .where(
          (PetProfile pet) =>
              allowedPetIds.contains(pet.id) &&
              pet.status == PetLifecycleStatus.active,
        )
        .toList(growable: false);
  }

  @override
  Future<List<PetProfile>> listRecoverableDeletedPets({
    required String accountId,
    required DateTime at,
  }) async {
    final allowedPetIds = _memberships
        .where(
          (PetMembership membership) =>
              membership.accountId == accountId &&
              membership.role == PetMembershipRole.owner &&
              membership.status == PetMembershipStatus.active,
        )
        .map((PetMembership membership) => membership.petId)
        .toSet();
    final deleted = _pets.values
        .where(
          (PetProfile pet) =>
              allowedPetIds.contains(pet.id) && pet.isRecoverableAt(at),
        )
        .toList();
    deleted.sort(
      (PetProfile a, PetProfile b) => b.deletedAt!.compareTo(a.deletedAt!),
    );
    return List<PetProfile>.unmodifiable(deleted);
  }

  @override
  Future<PetProfile> updateProfile({
    required String accountId,
    required String petId,
    required String name,
    required DateTime updatedAt,
    String? profileImagePath,
    PetType? requestedType,
  }) async {
    final pet = _pets[petId];
    if (pet == null) {
      throw const PetNotFoundFailure();
    }
    final ownsPet = _memberships.any(
      (PetMembership membership) =>
          membership.petId == petId &&
          membership.accountId == accountId &&
          membership.role == PetMembershipRole.owner &&
          membership.status == PetMembershipStatus.active,
    );
    if (!ownsPet) {
      throw const PetAccessDeniedFailure();
    }
    final updated = pet.updateEditableFields(
      name: name,
      profileImagePath: profileImagePath,
      requestedType: requestedType,
      updatedAt: updatedAt,
    );
    _pets[petId] = updated;
    return updated;
  }

  @override
  Future<PetProfile> softDeletePet({
    required String accountId,
    required String petId,
    required DateTime deletedAt,
  }) async {
    final pet = _ownedPet(accountId: accountId, petId: petId);
    final deleted = pet.softDelete(deletedAt: deletedAt);
    _pets[petId] = deleted;
    return deleted;
  }

  @override
  Future<PetProfile> restorePet({
    required String accountId,
    required String petId,
    required DateTime restoredAt,
  }) async {
    final pet = _ownedPet(accountId: accountId, petId: petId);
    final restored = pet.restore(restoredAt: restoredAt);
    _pets[petId] = restored;
    return restored;
  }

  PetProfile _ownedPet({required String accountId, required String petId}) {
    final pet = _pets[petId];
    if (pet == null) throw const PetNotFoundFailure();
    final ownsPet = _memberships.any(
      (PetMembership membership) =>
          membership.petId == petId &&
          membership.accountId == accountId &&
          membership.role == PetMembershipRole.owner &&
          membership.status == PetMembershipStatus.active,
    );
    if (!ownsPet) throw const PetAccessDeniedFailure();
    return pet;
  }
}
