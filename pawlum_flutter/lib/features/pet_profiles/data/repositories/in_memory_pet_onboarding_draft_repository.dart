import '../../domain/entities/pet_onboarding_draft.dart';
import '../../domain/repositories/pet_onboarding_draft_repository.dart';

class InMemoryPetOnboardingDraftRepository
    implements PetOnboardingDraftRepository {
  final Map<String, PetOnboardingDraft> _drafts =
      <String, PetOnboardingDraft>{};

  @override
  Future<void> clear(String accountId) async {
    _drafts.remove(accountId);
  }

  @override
  Future<PetOnboardingDraft?> load(String accountId) async {
    return _drafts[accountId];
  }

  @override
  Future<void> save(PetOnboardingDraft draft) async {
    _drafts[draft.accountId] = draft;
  }
}
