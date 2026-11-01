import '../entities/pet_initialization.dart';

abstract interface class AtomicPetJournalGateway {
  Future<PetInitializationResult> initialize(PetInitializationCommand command);
}
