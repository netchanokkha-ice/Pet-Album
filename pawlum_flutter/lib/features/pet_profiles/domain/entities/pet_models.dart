enum PetType { dog, cat, bird, rabbit, other }

enum PetLifecycleStatus { active, softDeleted }

enum PetMembershipRole { owner }

enum PetMembershipStatus { active, revoked }

enum PetOnboardingIssue {
  nameRequired,
  typeRequired,
  otherTypeLabelRequired,
  birthdayInFuture,
  firstMetDateInFuture,
}

class PetOnboardingInput {
  const PetOnboardingInput({
    required this.name,
    required this.type,
    this.customTypeLabel,
    this.profileImagePath,
    this.birthday,
    this.firstMetDate,
  });

  final String name;
  final PetType? type;
  final String? customTypeLabel;
  final String? profileImagePath;
  final DateTime? birthday;
  final DateTime? firstMetDate;

  List<PetOnboardingIssue> validate(DateTime today) {
    final issues = <PetOnboardingIssue>[];
    if (name.trim().isEmpty) {
      issues.add(PetOnboardingIssue.nameRequired);
    }
    if (type == null) {
      issues.add(PetOnboardingIssue.typeRequired);
    }
    if (type == PetType.other &&
        (customTypeLabel == null || customTypeLabel!.trim().isEmpty)) {
      issues.add(PetOnboardingIssue.otherTypeLabelRequired);
    }
    final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);
    if (birthday?.isAfter(endOfToday) ?? false) {
      issues.add(PetOnboardingIssue.birthdayInFuture);
    }
    if (firstMetDate?.isAfter(endOfToday) ?? false) {
      issues.add(PetOnboardingIssue.firstMetDateInFuture);
    }
    return List<PetOnboardingIssue>.unmodifiable(issues);
  }
}

class PetProfile {
  const PetProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.customTypeLabel,
    this.profileImagePath,
    this.birthday,
    this.firstMetDate,
    this.status = PetLifecycleStatus.active,
    this.deletedAt,
    this.deletionExpiresAt,
  });

  final String id;
  final String name;
  final PetType type;
  final String? customTypeLabel;
  final String? profileImagePath;
  final DateTime? birthday;
  final DateTime? firstMetDate;
  final PetLifecycleStatus status;
  final DateTime? deletedAt;
  final DateTime? deletionExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool isRecoverableAt(DateTime at) {
    final expiresAt = deletionExpiresAt;
    return status == PetLifecycleStatus.softDeleted &&
        expiresAt != null &&
        at.isBefore(expiresAt);
  }

  int recoveryDaysRemaining(DateTime at) {
    if (!isRecoverableAt(at)) return 0;
    final seconds = deletionExpiresAt!.difference(at).inSeconds;
    return (seconds + 86399) ~/ 86400;
  }

  PetProfile updateEditableFields({
    required String name,
    required DateTime updatedAt,
    String? profileImagePath,
    PetType? requestedType,
  }) {
    if (requestedType != null && requestedType != type) {
      throw const PetTypeImmutableFailure();
    }
    if (name.trim().isEmpty) {
      throw const PetOnboardingValidationFailure(<PetOnboardingIssue>[
        PetOnboardingIssue.nameRequired,
      ]);
    }
    return PetProfile(
      id: id,
      name: name.trim(),
      type: type,
      customTypeLabel: customTypeLabel,
      profileImagePath: profileImagePath,
      birthday: birthday,
      firstMetDate: firstMetDate,
      status: status,
      deletedAt: deletedAt,
      deletionExpiresAt: deletionExpiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  PetProfile softDelete({
    required DateTime deletedAt,
    Duration recoveryPeriod = const Duration(days: 7),
  }) {
    if (status == PetLifecycleStatus.softDeleted) return this;
    return PetProfile(
      id: id,
      name: name,
      type: type,
      customTypeLabel: customTypeLabel,
      profileImagePath: profileImagePath,
      birthday: birthday,
      firstMetDate: firstMetDate,
      status: PetLifecycleStatus.softDeleted,
      deletedAt: deletedAt,
      deletionExpiresAt: deletedAt.add(recoveryPeriod),
      createdAt: createdAt,
      updatedAt: deletedAt,
    );
  }

  PetProfile restore({required DateTime restoredAt}) {
    if (status == PetLifecycleStatus.active) return this;
    if (!isRecoverableAt(restoredAt)) {
      throw const PetDeletionExpiredFailure();
    }
    return PetProfile(
      id: id,
      name: name,
      type: type,
      customTypeLabel: customTypeLabel,
      profileImagePath: profileImagePath,
      birthday: birthday,
      firstMetDate: firstMetDate,
      createdAt: createdAt,
      updatedAt: restoredAt,
    );
  }
}

class PetMembership {
  const PetMembership({
    required this.petId,
    required this.accountId,
    required this.createdAt,
    this.role = PetMembershipRole.owner,
    this.status = PetMembershipStatus.active,
  });

  final String petId;
  final String accountId;
  final PetMembershipRole role;
  final PetMembershipStatus status;
  final DateTime createdAt;
}

class FirstMemoryMilestone {
  const FirstMemoryMilestone({
    required this.id,
    required this.petId,
    required this.memoryDate,
    required this.createdAt,
  });

  final String id;
  final String petId;
  final DateTime memoryDate;
  final DateTime createdAt;
}

class InitializedPetJournal {
  const InitializedPetJournal({
    required this.pet,
    required this.membership,
    required this.firstMemory,
  });

  final PetProfile pet;
  final PetMembership membership;
  final FirstMemoryMilestone firstMemory;
}

sealed class PetProfileFailure implements Exception {
  const PetProfileFailure();
}

class PetOnboardingValidationFailure extends PetProfileFailure {
  const PetOnboardingValidationFailure(this.issues);

  final List<PetOnboardingIssue> issues;
}

class PetTypeImmutableFailure extends PetProfileFailure {
  const PetTypeImmutableFailure();
}

class PetNotFoundFailure extends PetProfileFailure {
  const PetNotFoundFailure();
}

class PetAccessDeniedFailure extends PetProfileFailure {
  const PetAccessDeniedFailure();
}

class PetDeletionExpiredFailure extends PetProfileFailure {
  const PetDeletionExpiredFailure();
}
