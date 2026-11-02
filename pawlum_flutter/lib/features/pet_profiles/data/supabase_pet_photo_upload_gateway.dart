import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/pet_onboarding_draft.dart';

abstract interface class PetPhotoObjectStore {
  Future<void> upload({
    required String objectPath,
    required Uint8List bytes,
    required String mimeType,
  });
}

class SupabasePetPhotoObjectStore implements PetPhotoObjectStore {
  const SupabasePetPhotoObjectStore(this._client);

  static const String bucketName = 'pet-media';

  final SupabaseClient _client;

  @override
  Future<void> upload({
    required String objectPath,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    await _client.storage
        .from(bucketName)
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: mimeType,
            cacheControl: '3600',
          ),
        );
  }
}

class SupabasePetPhotoUploadGateway {
  const SupabasePetPhotoUploadGateway(this._store);

  final PetPhotoObjectStore _store;

  Future<String?> upload({
    required PetOnboardingDraft draft,
    required String petId,
  }) async {
    final bytes = draft.profileImageBytes;
    if (bytes == null) return draft.profileImagePath;

    final mimeType = draft.profileImageMimeType ?? 'image/jpeg';
    final extension = switch (mimeType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      'image/gif' => 'gif',
      _ => 'jpg',
    };
    final objectPath =
        '${draft.accountId}/$petId/profile/${draft.id}.$extension';
    await _store.upload(
      objectPath: objectPath,
      bytes: bytes,
      mimeType: mimeType,
    );
    return objectPath;
  }
}
