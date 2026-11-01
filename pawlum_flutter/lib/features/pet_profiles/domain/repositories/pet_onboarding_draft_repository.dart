import '../entities/pet_onboarding_draft.dart';

abstract interface class PetOnboardingDraftRepository {
  Future<PetOnboardingDraft?> load(String accountId);

  Future<void> save(PetOnboardingDraft draft);

  Future<void> clear(String accountId);
}
