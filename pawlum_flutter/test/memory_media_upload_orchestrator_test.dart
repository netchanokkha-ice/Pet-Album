import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/core/database/pawlum_database.dart';
import 'package:pawlum/core/sync/drift_sync_operation_store.dart';
import 'package:pawlum/features/memory_authoring/data/drift_memory_authoring_draft_repository.dart';
import 'package:pawlum/features/memory_authoring/data/memory_media_upload_orchestrator.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_authoring_draft.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_models.dart';
import 'package:pawlum/features/memory_authoring/domain/repositories/memory_media_binary_source.dart';
import 'package:pawlum/features/memory_authoring/domain/repositories/memory_media_upload_gateway.dart';

void main() {
  late Directory tempDirectory;
  late File databaseFile;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'pawlum-media-upload-test-',
    );
    databaseFile = File(
      '${tempDirectory.path}${Platform.pathSeparator}pawlum.sqlite',
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'partial upload restart completes without duplicate objects or records',
    () async {
      final gateway = _FakeUploadGateway()..failUploadOnceFor.add('media-2');
      final binarySource = _FakeBinarySource(<String, List<int>>{
        '/private/media-1.jpg': <int>[1, 2, 3],
        '/private/media-2.jpg': <int>[4, 5, 6],
      });
      final firstDatabase = _openDatabase(databaseFile);
      final firstDrafts = DriftMemoryAuthoringDraftRepository(firstDatabase);
      await firstDrafts.save(_draft());
      final first = MemoryMediaUploadOrchestrator(
        drafts: firstDrafts,
        binarySource: binarySource,
        gateway: gateway,
        operations: DriftSyncOperationStore(firstDatabase),
        clock: () => DateTime.utc(2026, 11, 1, 9),
      );

      final interrupted = await first.uploadDraft(
        accountId: 'account-a',
        draftId: 'draft-1',
      );
      expect(interrupted.isComplete, isFalse);
      expect(interrupted.uploadedMediaIds, <String>['media-1']);
      expect(interrupted.issues.single.mediaId, 'media-2');
      await firstDatabase.close();

      final secondDatabase = _openDatabase(databaseFile);
      final secondDrafts = DriftMemoryAuthoringDraftRepository(secondDatabase);
      final relaunched = MemoryMediaUploadOrchestrator(
        drafts: secondDrafts,
        binarySource: binarySource,
        gateway: gateway,
        operations: DriftSyncOperationStore(secondDatabase),
        clock: () => DateTime.utc(2026, 11, 1, 9, 1),
      );
      final completed = await relaunched.uploadDraft(
        accountId: 'account-a',
        draftId: 'draft-1',
      );

      expect(completed.isComplete, isTrue);
      expect(completed.uploadedMediaIds, <String>['media-2']);
      expect(gateway.objects, hasLength(2));
      expect(gateway.records, hasLength(2));
      expect(gateway.uploadAttempts['media-1'], 1);
      expect(gateway.uploadAttempts['media-2'], 2);
      final restored = await secondDrafts.load(
        accountId: 'account-a',
        draftId: 'draft-1',
      );
      expect(
        restored!.media.map((MemoryMedia media) => media.uploadState),
        everyElement(MemoryMediaUploadState.uploaded),
      );
      final operationRows = await secondDatabase
          .select(secondDatabase.syncOperations)
          .get();
      expect(operationRows, hasLength(2));
      expect(
        operationRows.where((row) => row.status == 'completed'),
        hasLength(2),
      );
      await secondDatabase.close();
    },
  );

  test('record failure removes the uncommitted object before retry', () async {
    final database = _openDatabase(databaseFile);
    final drafts = DriftMemoryAuthoringDraftRepository(database);
    await drafts.save(_draft(mediaCount: 1));
    final gateway = _FakeUploadGateway()..failRecordOnceFor.add('media-1');
    final orchestrator = MemoryMediaUploadOrchestrator(
      drafts: drafts,
      binarySource: _FakeBinarySource(<String, List<int>>{
        '/private/media-1.jpg': <int>[1, 2, 3],
      }),
      gateway: gateway,
      operations: DriftSyncOperationStore(database),
      clock: () => DateTime.utc(2026, 11, 1, 10),
    );

    final failed = await orchestrator.uploadDraft(
      accountId: 'account-a',
      draftId: 'draft-1',
    );
    expect(failed.isComplete, isFalse);
    expect(failed.issues.single.errorCode, 'media_record_failed');
    expect(failed.issues.single.orphanObjectPath, isNull);
    expect(gateway.objects, isEmpty);
    expect(gateway.records, isEmpty);

    final retried = await orchestrator.uploadDraft(
      accountId: 'account-a',
      draftId: 'draft-1',
    );
    expect(retried.isComplete, isTrue);
    expect(gateway.objects, hasLength(1));
    expect(gateway.records, hasLength(1));
    await database.close();
  });

  test(
    'matching checksum reuses the durable record without reupload',
    () async {
      final database = _openDatabase(databaseFile);
      final drafts = DriftMemoryAuthoringDraftRepository(database);
      await drafts.save(_draft(mediaCount: 1));
      final gateway = _FakeUploadGateway();
      gateway.records['media-1'] = const MemoryMediaRemoteRecord(
        mediaId: 'media-1',
        objectPath: 'account-a/memory-1/version-1/media-1.jpg',
        checksumSha256:
            '039058c6f2c0cb492c533b0a4d14ef77cc0f78abccced5287d84a1a2011cfb81',
      );
      final progress = <MemoryMediaUploadProgress>[];
      final orchestrator = MemoryMediaUploadOrchestrator(
        drafts: drafts,
        binarySource: _FakeBinarySource(<String, List<int>>{
          '/private/media-1.jpg': <int>[1, 2, 3],
        }),
        gateway: gateway,
        operations: DriftSyncOperationStore(database),
        clock: () => DateTime.utc(2026, 11, 1, 11),
      );

      final result = await orchestrator.uploadDraft(
        accountId: 'account-a',
        draftId: 'draft-1',
        onProgress: progress.add,
      );

      expect(result.isComplete, isTrue);
      expect(result.reusedMediaIds, <String>['media-1']);
      expect(result.uploadedMediaIds, isEmpty);
      expect(gateway.uploadAttempts, isEmpty);
      expect(progress.last.state, MemoryMediaUploadProgressState.uploaded);
      expect(progress.last.fraction, 1);
      await database.close();
    },
  );
}

MemoryAuthoringDraft _draft({int mediaCount = 2}) {
  final createdAt = DateTime.utc(2026, 11, 1, 8);
  return MemoryAuthoringDraft(
    accountId: 'account-a',
    id: 'draft-1',
    memoryId: 'memory-1',
    currentStep: 3,
    memoryDate: createdAt,
    createdAt: createdAt,
    updatedAt: createdAt,
    media: List<MemoryMedia>.generate(
      mediaCount,
      (int index) => MemoryMedia.create(
        id: 'media-${index + 1}',
        memoryVersionId: 'version-1',
        sourcePath: '/private/media-${index + 1}.jpg',
        type: MemoryMediaType.image,
        sortOrder: index,
        isCover: index == 0,
        mimeType: 'image/jpeg',
        byteSize: 3,
        createdAt: createdAt,
      ),
    ),
  );
}

PawlumDatabase _openDatabase(File file) =>
    PawlumDatabase.forTesting(NativeDatabase(file));

class _FakeBinarySource implements MemoryMediaBinarySource {
  _FakeBinarySource(this._files);

  final Map<String, List<int>> _files;

  @override
  Future<Uint8List> read(String localPath) async =>
      Uint8List.fromList(_files[localPath]!);
}

class _FakeUploadGateway implements MemoryMediaUploadGateway {
  final Map<String, MemoryMediaRemoteObject> objects =
      <String, MemoryMediaRemoteObject>{};
  final Map<String, MemoryMediaRemoteRecord> records =
      <String, MemoryMediaRemoteRecord>{};
  final Map<String, int> uploadAttempts = <String, int>{};
  final Set<String> failUploadOnceFor = <String>{};
  final Set<String> failRecordOnceFor = <String>{};

  @override
  Future<void> createRecord(MemoryMediaRecordDraft record) async {
    if (failRecordOnceFor.remove(record.media.id)) {
      throw StateError('simulated record failure');
    }
    if (records.containsKey(record.media.id)) {
      throw StateError('duplicate media record');
    }
    records[record.media.id] = MemoryMediaRemoteRecord(
      mediaId: record.media.id,
      objectPath: record.objectPath,
      checksumSha256: record.checksumSha256,
    );
  }

  @override
  Future<void> deleteObject(String objectPath) async {
    objects.remove(objectPath);
  }

  @override
  Future<MemoryMediaRemoteObject?> findObject(String objectPath) async =>
      objects[objectPath];

  @override
  Future<MemoryMediaRemoteRecord?> findRecord(String mediaId) async =>
      records[mediaId];

  @override
  Future<void> uploadObject({
    required String objectPath,
    required Uint8List bytes,
    required String checksumSha256,
    String? mimeType,
  }) async {
    final fileName = objectPath.substring(objectPath.lastIndexOf('/') + 1);
    final mediaId = fileName.substring(0, fileName.lastIndexOf('.'));
    uploadAttempts[mediaId] = (uploadAttempts[mediaId] ?? 0) + 1;
    if (failUploadOnceFor.remove(mediaId)) {
      throw StateError('simulated upload failure');
    }
    if (objects.containsKey(objectPath)) {
      throw StateError('duplicate object');
    }
    objects[objectPath] = MemoryMediaRemoteObject(
      objectPath: objectPath,
      checksumSha256: checksumSha256,
    );
  }
}
