import 'package:image_picker/image_picker.dart';

import '../domain/entities/memory_media_selection.dart';
import '../domain/entities/memory_models.dart';

class ImagePickerMemoryMediaPicker implements MemoryMediaPicker {
  ImagePickerMemoryMediaPicker(this._picker, {required this.idGenerator});

  final ImagePicker _picker;
  final String Function() idGenerator;

  @override
  Future<List<MemoryMediaCandidate>> pickImages({required int maxCount}) async {
    final files = await _picker.pickMultiImage(limit: maxCount);
    return Future.wait(
      files.map((XFile file) => _candidate(file, MemoryMediaType.image)),
    );
  }

  @override
  Future<MemoryMediaCandidate?> pickVideo({
    required Duration maxDuration,
  }) async {
    final file = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: maxDuration,
    );
    if (file == null) return null;
    return _candidate(file, MemoryMediaType.video);
  }

  Future<MemoryMediaCandidate> _candidate(
    XFile file,
    MemoryMediaType type,
  ) async {
    return MemoryMediaCandidate(
      id: idGenerator(),
      sourcePath: file.path,
      thumbnailPath: type == MemoryMediaType.image ? file.path : null,
      type: type,
      mimeType: file.mimeType ?? _mimeFromName(file.name, type),
      byteSize: await file.length(),
    );
  }

  String _mimeFromName(String name, MemoryMediaType type) {
    final extension = name.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      'mov' => 'video/quicktime',
      'webm' => 'video/webm',
      'mp4' => 'video/mp4',
      _ =>
        type == MemoryMediaType.image
            ? 'application/octet-stream+image'
            : 'application/octet-stream+video',
    };
  }
}
