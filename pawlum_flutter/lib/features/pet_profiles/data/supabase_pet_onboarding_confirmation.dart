import 'package:uuid/uuid.dart';

import '../domain/entities/pet_initialization.dart';
import '../domain/entities/pet_onboarding_draft.dart';
import '../domain/use_cases/confirm_pet_onboarding.dart';
import 'supabase_pet_photo_upload_gateway.dart';

class SupabasePetOnboardingConfirmation {
  const SupabasePetOnboardingConfirmation(
    this._photoUploadGateway,
    this._confirm,
  );

  final SupabasePetPhotoUploadGateway _photoUploadGateway;
  final ConfirmPetOnboarding _confirm;

  Future<void> call(PetOnboardingDraft draft) async {
    final ids = _idsFor(draft);
    final objectPath = await _photoUploadGateway.upload(
      draft: draft,
      petId: ids.petId,
    );
    final remoteDraft = draft.copyWith(
      profileImagePath: objectPath,
      clearProfileImageBytes: true,
      clearProfileImageFileName: true,
      clearProfileImageMimeType: true,
    );
    final outcome = await _confirm(
      PetInitializationCommand(ids: ids, draft: remoteDraft),
    );
    if (outcome != PetInitializationOutcome.completed) {
      throw const PetInitializationTransientFailure('pending_retry');
    }
  }

  PetInitializationIds _idsFor(PetOnboardingDraft draft) {
    final base = '${draft.accountId}:${draft.id}';
    const uuid = Uuid();
    return PetInitializationIds(
      petId: uuid.v5(Namespace.url.value, '$base:pet'),
      membershipId: uuid.v5(Namespace.url.value, '$base:membership'),
      memoryId: uuid.v5(Namespace.url.value, '$base:first-memory'),
      versionId: uuid.v5(Namespace.url.value, '$base:first-version'),
      relationId: uuid.v5(Namespace.url.value, '$base:relation'),
    );
  }
}
