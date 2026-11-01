import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/repositories/memory_media_upload_gateway.dart';

class SupabaseMemoryMediaUploadGateway implements MemoryMediaUploadGateway {
  const SupabaseMemoryMediaUploadGateway(this._client);

  static const String bucketName = 'memory-media';

  final SupabaseClient _client;

  @override
  Future<MemoryMediaRemoteRecord?> findRecord(String mediaId) async {
    final row = await _client
        .from('memory_media')
        .select('id, object_path, checksum_sha256')
        .eq('id', mediaId)
        .maybeSingle();
    if (row == null) return null;
    final checksum = row['checksum_sha256'];
    return MemoryMediaRemoteRecord(
      mediaId: row['id'] as String,
      objectPath: row['object_path'] as String,
      checksumSha256: checksum is String ? checksum : null,
    );
  }

  @override
  Future<MemoryMediaRemoteObject?> findObject(String objectPath) async {
    final separator = objectPath.lastIndexOf('/');
    final folder = separator < 0 ? '' : objectPath.substring(0, separator);
    final name = separator < 0
        ? objectPath
        : objectPath.substring(separator + 1);
    final objects = await _client.storage
        .from(bucketName)
        .list(
          path: folder,
          searchOptions: SearchOptions(limit: 2, search: name),
        );
    for (final object in objects) {
      if (object.name != name) continue;
      final metadata = object.metadata;
      final userMetadata = metadata?['metadata'];
      final checksum =
          metadata?['sha256'] ??
          (userMetadata is Map ? userMetadata['sha256'] : null);
      return MemoryMediaRemoteObject(
        objectPath: objectPath,
        checksumSha256: checksum is String ? checksum : null,
      );
    }
    return null;
  }

  @override
  Future<void> uploadObject({
    required String objectPath,
    required Uint8List bytes,
    required String checksumSha256,
    String? mimeType,
  }) async {
    await _client.storage
        .from(bucketName)
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(
            upsert: false,
            contentType: mimeType,
            metadata: <String, String>{'sha256': checksumSha256},
          ),
        );
  }

  @override
  Future<void> createRecord(MemoryMediaRecordDraft record) async {
    final media = record.media;
    await _client.from('memory_media').insert(<String, Object?>{
      'id': media.id,
      'memory_version_id': media.memoryVersionId,
      'object_path': record.objectPath,
      'thumbnail_object_path': media.thumbnailPath,
      'media_type': media.type.name,
      'sort_order': media.sortOrder,
      'is_cover': media.isCover,
      'mime_type': media.mimeType,
      'byte_size': media.byteSize,
      'pixel_width': media.pixelWidth,
      'pixel_height': media.pixelHeight,
      'duration_ms': media.duration?.inMilliseconds,
      'presentation_data': media.presentationData,
      'upload_state': 'uploaded',
      'checksum_sha256': record.checksumSha256,
      'created_at': media.createdAt.toIso8601String(),
      'updated_at': media.updatedAt.toIso8601String(),
    });
  }

  @override
  Future<void> deleteObject(String objectPath) =>
      _client.storage.from(bucketName).remove(<String>[objectPath]);
}
