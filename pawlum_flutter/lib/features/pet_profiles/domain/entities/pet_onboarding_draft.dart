import 'dart:typed_data';

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
    this.profileImageBytes,
    this.profileImageFileName,
    this.profileImageMimeType,
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
  final Uint8List? profileImageBytes;
  final String? profileImageFileName;
  final String? profileImageMimeType;
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
    Uint8List? profileImageBytes,
    bool clearProfileImageBytes = false,
    String? profileImageFileName,
    bool clearProfileImageFileName = false,
    String? profileImageMimeType,
    bool clearProfileImageMimeType = false,
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
      profileImageBytes: clearProfileImageBytes
          ? null
          : profileImageBytes ?? this.profileImageBytes,
      profileImageFileName: clearProfileImageFileName
          ? null
          : profileImageFileName ?? this.profileImageFileName,
      profileImageMimeType: clearProfileImageMimeType
          ? null
          : profileImageMimeType ?? this.profileImageMimeType,
      birthday: clearBirthday ? null : birthday ?? this.birthday,
      firstMetDate: clearFirstMetDate
          ? null
          : firstMetDate ?? this.firstMetDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PetPhotoSelection {
  const PetPhotoSelection({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
}
