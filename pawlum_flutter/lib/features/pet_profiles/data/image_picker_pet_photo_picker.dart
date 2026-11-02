import 'package:image_picker/image_picker.dart';

import '../domain/entities/pet_onboarding_draft.dart';
import '../presentation/controllers/pet_onboarding_controller.dart';

class ImagePickerPetPhotoPicker implements PetPhotoPicker {
  ImagePickerPetPhotoPicker(this._picker);

  static const int maxBytes = 10 * 1024 * 1024;

  final ImagePicker _picker;

  @override
  Future<PetPhotoSelection?> pickPhoto() async {
    final selected = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 88,
    );
    if (selected == null) return null;

    if (await selected.length() > maxBytes) {
      throw const PetPhotoSelectionFailure();
    }
    final bytes = await selected.readAsBytes();
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const PetPhotoSelectionFailure();
    }
    return PetPhotoSelection(
      bytes: bytes,
      fileName: selected.name,
      mimeType: selected.mimeType ?? _mimeTypeFor(selected.name),
    );
  }

  String _mimeTypeFor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}

class PetPhotoSelectionFailure implements Exception {
  const PetPhotoSelectionFailure();
}
