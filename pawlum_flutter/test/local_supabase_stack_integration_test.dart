import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/features/memory_authoring/data/supabase_memory_media_upload_gateway.dart';
import 'package:pawlum/features/memory_authoring/data/supabase_memory_publication_repository.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_models.dart';
import 'package:pawlum/features/memory_authoring/domain/repositories/memory_media_upload_gateway.dart';
import 'package:pawlum/features/pet_profiles/data/data_sources/supabase_pet_journal_gateway.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_initialization.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_models.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_onboarding_draft.dart';
import 'package:pawlum/features/timeline/data/supabase_timeline_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _localUrl = String.fromEnvironment('LOCAL_SUPABASE_URL');
const _localKey = String.fromEnvironment('LOCAL_SUPABASE_KEY');
const _hasLocalStack = _localUrl != '' && _localKey != '';

void main() {
  test(
    'Flutter client completes the private journal flow on local Supabase',
    () async {
      const authOptions = AuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      );
      final owner = SupabaseClient(
        _localUrl,
        _localKey,
        authOptions: authOptions,
      );
      final outsider = SupabaseClient(
        _localUrl,
        _localKey,
        authOptions: authOptions,
      );
      addTearDown(owner.dispose);
      addTearDown(outsider.dispose);

      final ownerAuth = await owner.auth.signUp(
        email: 'flutter-owner@pawlum.local',
        password: 'local-owner-password',
      );
      final ownerId = ownerAuth.user!.id;
      expect(ownerAuth.session, isNotNull);

      const ids = PetInitializationIds(
        petId: '11111111-1111-4111-8111-111111111111',
        membershipId: '22222222-2222-4222-8222-222222222222',
        memoryId: '33333333-3333-4333-8333-333333333333',
        versionId: '44444444-4444-4444-8444-444444444444',
        relationId: '55555555-5555-4555-8555-555555555555',
      );
      final initialized =
          await SupabaseAtomicPetJournalGateway(
            SupabasePetJournalRpcClient(owner),
          ).initialize(
            PetInitializationCommand(
              ids: ids,
              draft: PetOnboardingDraft(
                accountId: ownerId,
                id: 'local-integration',
                step: PetOnboardingStep.confirmation,
                name: 'Local Mochi',
                type: PetType.cat,
                updatedAt: DateTime.utc(2026, 11, 1),
              ),
            ),
          );
      expect(initialized.replayed, isFalse);
      expect(initialized.memoryId, ids.memoryId);

      final originalObjectPath =
          '$ownerId/${ids.memoryId}/${ids.versionId}/original.jpg';
      final mediaGateway = SupabaseMemoryMediaUploadGateway(owner);
      final originalBytes = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
      final originalChecksum = List<String>.filled(64, 'a').join();
      await mediaGateway.uploadObject(
        objectPath: originalObjectPath,
        bytes: originalBytes,
        checksumSha256: originalChecksum,
        mimeType: 'image/jpeg',
      );
      final originalMedia = MemoryMedia.create(
        id: '66666666-6666-4666-8666-666666666666',
        memoryVersionId: ids.versionId,
        sourcePath: '/private/local-original.jpg',
        type: MemoryMediaType.image,
        sortOrder: 0,
        isCover: true,
        createdAt: DateTime.utc(2026, 11, 1),
        mimeType: 'image/jpeg',
        byteSize: originalBytes.length,
      );
      await mediaGateway.createRecord(
        MemoryMediaRecordDraft(
          media: originalMedia,
          objectPath: originalObjectPath,
          checksumSha256: originalChecksum,
        ),
      );

      final publication = SupabaseMemoryPublicationRepository(
        SupabaseMemoryPublicationRpcClient(owner),
      );
      final published = await publication.publish(
        memoryId: ids.memoryId,
        versionId: ids.versionId,
      );
      expect(published.replayed, isFalse);

      final timeline = SupabaseTimelineRepository(
        SupabaseTimelineRpcClient(owner),
      );
      final publishedPage = await timeline.loadPage(petId: ids.petId);
      expect(publishedPage.entries, hasLength(1));
      expect(publishedPage.entries.single.memoryId, ids.memoryId);

      const editVersionId = '77777777-7777-4777-8777-777777777777';
      final edit = await publication.beginOrResumeEdit(
        memoryId: ids.memoryId,
        proposedVersionId: editVersionId,
      );
      expect(edit.resumed, isFalse);
      await owner
          .from('memory_versions')
          .update(<String, Object?>{
            'title': 'Edited local memory',
            'caption': 'Promoted through the Flutter Supabase adapter.',
          })
          .eq('id', editVersionId);

      final editedObjectPath =
          '$ownerId/${ids.memoryId}/$editVersionId/edited.jpg';
      final editedBytes = Uint8List.fromList(<int>[6, 7, 8, 9]);
      final editedChecksum = List<String>.filled(64, 'b').join();
      await mediaGateway.uploadObject(
        objectPath: editedObjectPath,
        bytes: editedBytes,
        checksumSha256: editedChecksum,
        mimeType: 'image/jpeg',
      );
      final editedMedia = MemoryMedia.create(
        id: '88888888-8888-4888-8888-888888888888',
        memoryVersionId: editVersionId,
        sourcePath: '/private/local-edited.jpg',
        type: MemoryMediaType.image,
        sortOrder: 0,
        isCover: true,
        createdAt: DateTime.utc(2026, 11, 1, 0, 1),
        mimeType: 'image/jpeg',
        byteSize: editedBytes.length,
      );
      await mediaGateway.createRecord(
        MemoryMediaRecordDraft(
          media: editedMedia,
          objectPath: editedObjectPath,
          checksumSha256: editedChecksum,
        ),
      );
      final promoted = await publication.publishChanges(
        memoryId: ids.memoryId,
        versionId: editVersionId,
      );
      expect(promoted.publishedVersionId, editVersionId);

      final editedPage = await timeline.loadPage(petId: ids.petId);
      expect(editedPage.entries.single.title, 'Edited local memory');
      expect(
        await owner.storage
            .from(SupabaseMemoryMediaUploadGateway.bucketName)
            .download(editedObjectPath),
        editedBytes,
      );

      final deletedAt = DateTime.now().toUtc();
      await owner
          .from('memories')
          .update(<String, Object?>{
            'lifecycle_status': 'soft_deleted',
            'deleted_at': deletedAt.toIso8601String(),
            'deletion_expires_at': deletedAt
                .add(const Duration(days: 7))
                .toIso8601String(),
            'pre_deletion_status': 'published',
          })
          .eq('id', ids.memoryId);
      expect((await timeline.loadPage(petId: ids.petId)).entries, isEmpty);
      await owner
          .from('memories')
          .update(<String, Object?>{
            'lifecycle_status': 'published',
            'deleted_at': null,
            'deletion_expires_at': null,
            'pre_deletion_status': null,
          })
          .eq('id', ids.memoryId);
      expect((await timeline.loadPage(petId: ids.petId)).entries, hasLength(1));

      final outsiderAuth = await outsider.auth.signUp(
        email: 'flutter-outsider@pawlum.local',
        password: 'local-outsider-password',
      );
      expect(outsiderAuth.session, isNotNull);
      expect(await outsider.from('pets').select('id'), isEmpty);
      await expectLater(
        outsider.rpc<Object?>(
          'publish_memory',
          params: <String, Object?>{
            'p_memory_id': ids.memoryId,
            'p_version_id': editVersionId,
          },
        ),
        throwsA(isA<PostgrestException>()),
      );
      await expectLater(
        outsider.storage
            .from(SupabaseMemoryMediaUploadGateway.bucketName)
            .download(editedObjectPath),
        throwsA(isA<StorageException>()),
      );
      await owner.storage
          .from(SupabaseMemoryMediaUploadGateway.bucketName)
          .remove(<String>[originalObjectPath, editedObjectPath]);
    },
    skip: _hasLocalStack
        ? false
        : 'Pass LOCAL_SUPABASE_URL and LOCAL_SUPABASE_KEY dart-defines.',
  );
}
