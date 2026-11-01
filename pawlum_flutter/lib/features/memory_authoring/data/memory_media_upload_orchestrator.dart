import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../../core/sync/sync_operation.dart';
import '../../../core/sync/sync_operation_store.dart';
import '../domain/entities/memory_authoring_draft.dart';
import '../domain/entities/memory_models.dart';
import '../domain/repositories/memory_authoring_draft_repository.dart';
import '../domain/repositories/memory_media_binary_source.dart';
import '../domain/repositories/memory_media_upload_gateway.dart';

enum MemoryMediaUploadProgressState { queued, uploading, uploaded, failed }

class MemoryMediaUploadProgress {
  const MemoryMediaUploadProgress({
    required this.mediaId,
    required this.state,
    required this.completedItems,
    required this.totalItems,
    required this.completedBytes,
    required this.totalBytes,
    this.errorCode,
  });

  final String mediaId;
  final MemoryMediaUploadProgressState state;
  final int completedItems;
  final int totalItems;
  final int completedBytes;
  final int totalBytes;
  final String? errorCode;

  double get fraction {
    if (totalItems == 0) return 1;
    final currentItemFraction =
        state == MemoryMediaUploadProgressState.uploading
        ? completedBytes / (totalBytes == 0 ? 1 : totalBytes)
        : 0;
    return ((completedItems + currentItemFraction) / totalItems).clamp(0, 1);
  }
}

class MemoryMediaUploadIssue {
  const MemoryMediaUploadIssue({
    required this.mediaId,
    required this.errorCode,
    this.orphanObjectPath,
  });

  final String mediaId;
  final String errorCode;
  final String? orphanObjectPath;
}

class MemoryMediaUploadBatchResult {
  MemoryMediaUploadBatchResult({
    required this.uploadedMediaIds,
    required this.reusedMediaIds,
    required this.issues,
  });

  final List<String> uploadedMediaIds;
  final List<String> reusedMediaIds;
  final List<MemoryMediaUploadIssue> issues;

  bool get isComplete => issues.isEmpty;
}

class MemoryMediaUploadOrchestrator {
  factory MemoryMediaUploadOrchestrator({
    required MemoryAuthoringDraftRepository drafts,
    required MemoryMediaBinarySource binarySource,
    required MemoryMediaUploadGateway gateway,
    required SyncOperationStore operations,
    DateTime Function()? clock,
  }) => MemoryMediaUploadOrchestrator._(
    drafts,
    binarySource,
    gateway,
    operations,
    clock ?? DateTime.now,
  );

  MemoryMediaUploadOrchestrator._(
    this._drafts,
    this._binarySource,
    this._gateway,
    this._operations,
    this._clock,
  );

  final MemoryAuthoringDraftRepository _drafts;
  final MemoryMediaBinarySource _binarySource;
  final MemoryMediaUploadGateway _gateway;
  final SyncOperationStore _operations;
  final DateTime Function() _clock;

  Future<MemoryMediaUploadBatchResult> uploadDraft({
    required String accountId,
    required String draftId,
    void Function(MemoryMediaUploadProgress progress)? onProgress,
  }) async {
    await _operations.recoverInterrupted(
      accountId: accountId,
      recoveredAt: _clock(),
    );
    final recoveredDraft = await _drafts.load(
      accountId: accountId,
      draftId: draftId,
    );
    if (recoveredDraft == null) {
      throw StateError('Memory draft not found in the account scope.');
    }
    var draft = recoveredDraft;

    final candidates = draft.media
        .where(
          (MemoryMedia media) =>
              media.uploadState != MemoryMediaUploadState.removed,
        )
        .toList(growable: false);
    final uploaded = <String>[];
    final reused = <String>[];
    final issues = <MemoryMediaUploadIssue>[];
    var completedItems = candidates
        .where(
          (MemoryMedia media) =>
              media.uploadState == MemoryMediaUploadState.uploaded,
        )
        .length;

    for (final original in candidates) {
      if (original.uploadState == MemoryMediaUploadState.uploaded) continue;
      final bytes = await _binarySource.read(original.sourcePath);
      final checksum = sha256.convert(bytes).toString();
      final operation = await _operations.enqueue(
        SyncOperationDraft(
          accountId: accountId,
          id: 'memory-media-upload:${original.id}:$checksum',
          aggregateType: 'memory_media',
          aggregateId: original.id,
          operationType: 'upload',
          commandId: checksum,
          createdAt: _clock(),
          payloadJson: '{"draft_id":"$draftId"}',
        ),
      );

      var media = _queueForRetry(original, _clock());
      draft = await _replaceAndSave(draft, media);
      onProgress?.call(
        MemoryMediaUploadProgress(
          mediaId: media.id,
          state: MemoryMediaUploadProgressState.queued,
          completedItems: completedItems,
          totalItems: candidates.length,
          completedBytes: 0,
          totalBytes: bytes.length,
        ),
      );
      await _operations.markRunning(
        accountId: accountId,
        operationId: operation.id,
        startedAt: _clock(),
      );
      media = media.startUpload(_clock());
      draft = await _replaceAndSave(draft, media);
      onProgress?.call(
        MemoryMediaUploadProgress(
          mediaId: media.id,
          state: MemoryMediaUploadProgressState.uploading,
          completedItems: completedItems,
          totalItems: candidates.length,
          completedBytes: 0,
          totalBytes: bytes.length,
        ),
      );

      final objectPath = _objectPath(
        accountId: accountId,
        memoryId: draft.memoryId,
        media: media,
      );
      try {
        final wasReused = await _ensureRemote(
          media: media,
          bytes: bytes,
          checksum: checksum,
          objectPath: objectPath,
        );
        media = media.markUploaded(at: _clock(), checksumSha256: checksum);
        draft = await _replaceAndSave(draft, media);
        await _operations.markCompleted(
          accountId: accountId,
          operationId: operation.id,
          completedAt: _clock(),
          remoteRevision: checksum,
        );
        completedItems += 1;
        (wasReused ? reused : uploaded).add(media.id);
        onProgress?.call(
          MemoryMediaUploadProgress(
            mediaId: media.id,
            state: MemoryMediaUploadProgressState.uploaded,
            completedItems: completedItems,
            totalItems: candidates.length,
            completedBytes: bytes.length,
            totalBytes: bytes.length,
          ),
        );
      } on _UploadFailure catch (failure) {
        media = media.markFailed(_clock());
        draft = await _replaceAndSave(draft, media);
        await _operations.markTransientFailure(
          accountId: accountId,
          operationId: operation.id,
          errorCode: failure.errorCode,
          failedAt: _clock(),
        );
        issues.add(
          MemoryMediaUploadIssue(
            mediaId: media.id,
            errorCode: failure.errorCode,
            orphanObjectPath: failure.orphanObjectPath,
          ),
        );
        onProgress?.call(
          MemoryMediaUploadProgress(
            mediaId: media.id,
            state: MemoryMediaUploadProgressState.failed,
            completedItems: completedItems,
            totalItems: candidates.length,
            completedBytes: 0,
            totalBytes: bytes.length,
            errorCode: failure.errorCode,
          ),
        );
      } on Object {
        media = media.markFailed(_clock());
        draft = await _replaceAndSave(draft, media);
        await _operations.markTransientFailure(
          accountId: accountId,
          operationId: operation.id,
          errorCode: 'upload_failed',
          failedAt: _clock(),
        );
        issues.add(
          MemoryMediaUploadIssue(
            mediaId: media.id,
            errorCode: 'upload_failed',
            orphanObjectPath: objectPath,
          ),
        );
        onProgress?.call(
          MemoryMediaUploadProgress(
            mediaId: media.id,
            state: MemoryMediaUploadProgressState.failed,
            completedItems: completedItems,
            totalItems: candidates.length,
            completedBytes: 0,
            totalBytes: bytes.length,
            errorCode: 'upload_failed',
          ),
        );
      }
    }

    return MemoryMediaUploadBatchResult(
      uploadedMediaIds: List<String>.unmodifiable(uploaded),
      reusedMediaIds: List<String>.unmodifiable(reused),
      issues: List<MemoryMediaUploadIssue>.unmodifiable(issues),
    );
  }

  Future<bool> _ensureRemote({
    required MemoryMedia media,
    required Uint8List bytes,
    required String checksum,
    required String objectPath,
  }) async {
    final record = await _gateway.findRecord(media.id);
    if (record != null) {
      if (record.objectPath == objectPath &&
          record.checksumSha256 == checksum) {
        return true;
      }
      throw const _UploadFailure('remote_media_conflict');
    }

    var object = await _gateway.findObject(objectPath);
    if (object != null && object.checksumSha256 != checksum) {
      await _gateway.deleteObject(objectPath);
      object = null;
    }
    var uploadedNow = false;
    if (object == null) {
      try {
        await _gateway.uploadObject(
          objectPath: objectPath,
          bytes: bytes,
          checksumSha256: checksum,
          mimeType: media.mimeType,
        );
        uploadedNow = true;
      } on Object {
        final uncertainObject = await _safeFindObject(objectPath);
        if (uncertainObject?.checksumSha256 != checksum) {
          throw const _UploadFailure('object_upload_failed');
        }
      }
    }

    try {
      await _gateway.createRecord(
        MemoryMediaRecordDraft(
          media: media,
          objectPath: objectPath,
          checksumSha256: checksum,
        ),
      );
    } on Object {
      try {
        await _gateway.deleteObject(objectPath);
      } on Object {
        throw _UploadFailure(
          'media_record_failed',
          orphanObjectPath: objectPath,
        );
      }
      throw const _UploadFailure('media_record_failed');
    }
    return !uploadedNow;
  }

  Future<MemoryMediaRemoteObject?> _safeFindObject(String objectPath) async {
    try {
      return await _gateway.findObject(objectPath);
    } on Object {
      return null;
    }
  }

  MemoryMedia _queueForRetry(MemoryMedia media, DateTime at) {
    return switch (media.uploadState) {
      MemoryMediaUploadState.localSelected ||
      MemoryMediaUploadState.failed => media.queue(at),
      MemoryMediaUploadState.uploading => media.markFailed(at).queue(at),
      MemoryMediaUploadState.queued => media,
      MemoryMediaUploadState.uploaded ||
      MemoryMediaUploadState.removed => media,
    };
  }

  Future<MemoryAuthoringDraft> _replaceAndSave(
    MemoryAuthoringDraft draft,
    MemoryMedia replacement,
  ) async {
    final updated = MemoryAuthoringDraft(
      accountId: draft.accountId,
      id: draft.id,
      memoryId: draft.memoryId,
      draftKind: draft.draftKind,
      currentStep: draft.currentStep,
      title: draft.title,
      caption: draft.caption,
      mood: draft.mood,
      location: draft.location,
      occasion: draft.occasion,
      memoryDate: draft.memoryDate,
      themeKey: draft.themeKey,
      templateKey: draft.templateKey,
      layoutKey: draft.layoutKey,
      pendingSync: true,
      media: draft.media
          .map(
            (MemoryMedia media) =>
                media.id == replacement.id ? replacement : media,
          )
          .toList(growable: false),
      createdAt: draft.createdAt,
      updatedAt: _clock(),
    );
    await _drafts.save(updated);
    return updated;
  }

  String _objectPath({
    required String accountId,
    required String memoryId,
    required MemoryMedia media,
  }) {
    final source = media.sourcePath.toLowerCase();
    final dot = source.lastIndexOf('.');
    final rawExtension = dot < 0 ? '' : source.substring(dot + 1);
    final extension = RegExp(r'^[a-z0-9]{1,8}$').hasMatch(rawExtension)
        ? '.$rawExtension'
        : '';
    return '$accountId/$memoryId/${media.memoryVersionId}/${media.id}$extension';
  }
}

class _UploadFailure implements Exception {
  const _UploadFailure(this.errorCode, {this.orphanObjectPath});

  final String errorCode;
  final String? orphanObjectPath;
}
