import 'dart:typed_data';

import '../entities/memory_models.dart';

class MemoryMediaRemoteRecord {
  const MemoryMediaRemoteRecord({
    required this.mediaId,
    required this.objectPath,
    required this.checksumSha256,
  });

  final String mediaId;
  final String objectPath;
  final String? checksumSha256;
}

class MemoryMediaRemoteObject {
  const MemoryMediaRemoteObject({
    required this.objectPath,
    required this.checksumSha256,
  });

  final String objectPath;
  final String? checksumSha256;
}

class MemoryMediaRecordDraft {
  const MemoryMediaRecordDraft({
    required this.media,
    required this.objectPath,
    required this.checksumSha256,
  });

  final MemoryMedia media;
  final String objectPath;
  final String checksumSha256;
}

abstract interface class MemoryMediaUploadGateway {
  Future<MemoryMediaRemoteRecord?> findRecord(String mediaId);

  Future<MemoryMediaRemoteObject?> findObject(String objectPath);

  Future<void> uploadObject({
    required String objectPath,
    required Uint8List bytes,
    required String checksumSha256,
    String? mimeType,
  });

  Future<void> createRecord(MemoryMediaRecordDraft record);

  Future<void> deleteObject(String objectPath);
}
