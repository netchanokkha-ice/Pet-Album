import '../entities/pet_models.dart';

class InitializePetJournalCommand {
  const InitializePetJournalCommand({
    required this.accountId,
    required this.petId,
    required this.firstMemoryId,
    required this.input,
    required this.createdAt,
  });

  final String accountId;
  final String petId;
  final String firstMemoryId;
  final PetOnboardingInput input;
  final DateTime createdAt;
}

abstract interface class PetProfileRepository {
  Future<List<PetProfile>> listActivePets(String accountId);

  Future<List<PetProfile>> listRecoverableDeletedPets({
    required String accountId,
    required DateTime at,
  });

  Future<InitializedPetJournal> initializePetJournal(
    InitializePetJournalCommand command,
  );

  Future<PetProfile> updateProfile({
    required String accountId,
    required String petId,
    required String name,
    required DateTime updatedAt,
    String? profileImagePath,
    PetType? requestedType,
  });

  Future<PetProfile> softDeletePet({
    required String accountId,
    required String petId,
    required DateTime deletedAt,
  });

  Future<PetProfile> restorePet({
    required String accountId,
    required String petId,
    required DateTime restoredAt,
  });
}
