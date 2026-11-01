import 'pet_models.dart';

enum PetOnboardingStep { welcome, petInfo, photo, confirmation }

class PetOnboardingDraft {
  const PetOnboardingDraft({
    required this.accountId,
    required this.id,
    required this.step,
    required this.updatedAt,
    this.name = '',
    this.type,
    this.customTypeLabel,
    this.profileImagePath,
    this.birthday,
    this.firstMetDate,
  });

  final String accountId;
  final String id;
  final PetOnboardingStep step;
  final String name;
  final PetType? type;
  final String? customTypeLabel;
  final String? profileImagePath;
  final DateTime? birthday;
  final DateTime? firstMetDate;
  final DateTime updatedAt;

  PetOnboardingInput get input => PetOnboardingInput(
    name: name,
    type: type,
    customTypeLabel: customTypeLabel,
    profileImagePath: profileImagePath,
    birthday: birthday,
    firstMetDate: firstMetDate,
  );

  PetOnboardingDraft copyWith({
    PetOnboardingStep? step,
    String? name,
    PetType? type,
    bool clearType = false,
    String? customTypeLabel,
    bool clearCustomTypeLabel = false,
    String? profileImagePath,
    bool clearProfileImagePath = false,
    DateTime? birthday,
    bool clearBirthday = false,
    DateTime? firstMetDate,
    bool clearFirstMetDate = false,
    DateTime? updatedAt,
  }) {
    return PetOnboardingDraft(
      accountId: accountId,
      id: id,
      step: step ?? this.step,
      name: name ?? this.name,
      type: clearType ? null : type ?? this.type,
      customTypeLabel: clearCustomTypeLabel
          ? null
          : customTypeLabel ?? this.customTypeLabel,
      profileImagePath: clearProfileImagePath
          ? null
          : profileImagePath ?? this.profileImagePath,
      birthday: clearBirthday ? null : birthday ?? this.birthday,
      firstMetDate: clearFirstMetDate
          ? null
          : firstMetDate ?? this.firstMetDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
