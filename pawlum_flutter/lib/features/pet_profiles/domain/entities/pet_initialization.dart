import 'pet_onboarding_draft.dart';

class PetInitializationIds {
  const PetInitializationIds({
    required this.petId,
    required this.membershipId,
    required this.memoryId,
    required this.versionId,
    required this.relationId,
  });

  final String petId;
  final String membershipId;
  final String memoryId;
  final String versionId;
  final String relationId;
}

class PetInitializationCommand {
  const PetInitializationCommand({required this.ids, required this.draft});

  final PetInitializationIds ids;
  final PetOnboardingDraft draft;
}

class PetInitializationResult {
  const PetInitializationResult({
    required this.petId,
    required this.memoryId,
    required this.workingVersionId,
    required this.replayed,
  });

  final String petId;
  final String memoryId;
  final String workingVersionId;
  final bool replayed;
}

enum PetInitializationOutcome { completed, pendingRetry }

class PetInitializationTransientFailure implements Exception {
  const PetInitializationTransientFailure(this.code);

  final String code;
}
