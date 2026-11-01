import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/pawlum_database.dart';
import '../domain/entities/memory_authoring_draft.dart';
import '../domain/entities/memory_models.dart';
import '../domain/repositories/memory_authoring_draft_repository.dart';

class DriftMemoryAuthoringDraftRepository
    implements MemoryAuthoringDraftRepository {
  DriftMemoryAuthoringDraftRepository(this._database);

  final PawlumDatabase _database;

  @override
  Future<MemoryAuthoringDraft?> load({
    required String accountId,
    required String draftId,
  }) async {
    final row =
        await (_database.select(_database.memoryDrafts)..where(
              (MemoryDrafts table) =>
                  table.accountId.equals(accountId) & table.id.equals(draftId),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    final payload = _object(jsonDecode(row.payloadJson));
    final mediaRows =
        await (_database.select(_database.localMediaReferences)
              ..where(
                (LocalMediaReferences table) =>
                    table.accountId.equals(accountId) &
                    table.ownerDraftType.equals('memory') &
                    table.ownerDraftId.equals(draftId),
              )
              ..orderBy(<OrderingTerm Function(LocalMediaReferences)>[
                (LocalMediaReferences table) =>
                    OrderingTerm.asc(table.sortOrder),
              ]))
            .get();
    final media = mediaRows
        .map((LocalMediaReferenceRow mediaRow) {
          final metadata = _object(jsonDecode(mediaRow.metadataJson));
          return MemoryMedia.create(
            id: mediaRow.id,
            memoryVersionId:
                metadata['memory_version_id'] as String? ??
                'local-working-version',
            sourcePath: mediaRow.localPath,
            thumbnailPath: metadata['thumbnail_path'] as String?,
            type: _mediaType(mediaRow.mediaType),
            sortOrder: mediaRow.sortOrder,
            isCover: metadata['is_cover'] as bool? ?? false,
            mimeType: metadata['mime_type'] as String?,
            byteSize: metadata['byte_size'] as int?,
            pixelWidth: metadata['pixel_width'] as int?,
            pixelHeight: metadata['pixel_height'] as int?,
            duration: _duration(metadata['duration_ms']),
            presentationData: _object(metadata['presentation_data']),
            uploadState: _uploadState(mediaRow.uploadState),
            checksumSha256: mediaRow.checksum,
            createdAt: DateTime.parse(
              metadata['created_at'] as String? ??
                  row.createdAt.toIso8601String(),
            ),
          );
        })
        .toList(growable: false);
    return MemoryAuthoringDraft(
      accountId: row.accountId,
      id: row.id,
      memoryId: row.memoryId,
      draftKind: row.draftKind,
      currentStep: row.currentStep,
      title: payload['title'] as String? ?? '',
      caption: payload['caption'] as String? ?? '',
      mood: payload['mood'] as String? ?? '',
      location: payload['location'] as String? ?? '',
      occasion: payload['occasion'] as String? ?? '',
      memoryDate: DateTime.parse(payload['memory_date'] as String),
      themeKey: payload['theme_key'] as String? ?? 'pawlum_default',
      templateKey: payload['template_key'] as String? ?? 'classic',
      layoutKey: payload['layout_key'] as String? ?? 'single',
      pendingSync: payload['pending_sync'] as bool? ?? true,
      media: media,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> save(MemoryAuthoringDraft draft) async {
    await _database.transaction(() async {
      await _database
          .into(_database.memoryDrafts)
          .insertOnConflictUpdate(
            MemoryDraftsCompanion.insert(
              accountId: draft.accountId,
              id: draft.id,
              memoryId: draft.memoryId,
              draftKind: draft.draftKind,
              currentStep: Value<int>(draft.currentStep),
              payloadJson: Value<String>(
                jsonEncode(<String, Object?>{
                  'title': draft.title,
                  'caption': draft.caption,
                  'mood': draft.mood,
                  'location': draft.location,
                  'occasion': draft.occasion,
                  'memory_date': draft.memoryDate.toIso8601String(),
                  'theme_key': draft.themeKey,
                  'template_key': draft.templateKey,
                  'layout_key': draft.layoutKey,
                  'pending_sync': draft.pendingSync,
                }),
              ),
              createdAt: draft.createdAt,
              updatedAt: draft.updatedAt,
            ),
          );
      await (_database.delete(_database.localMediaReferences)..where(
            (LocalMediaReferences table) =>
                table.accountId.equals(draft.accountId) &
                table.ownerDraftType.equals('memory') &
                table.ownerDraftId.equals(draft.id),
          ))
          .go();
      for (final media in draft.media) {
        await _database
            .into(_database.localMediaReferences)
            .insert(
              LocalMediaReferencesCompanion.insert(
                accountId: draft.accountId,
                id: media.id,
                ownerDraftType: 'memory',
                ownerDraftId: draft.id,
                localPath: media.sourcePath,
                mediaType: media.type.name,
                sortOrder: Value<int>(media.sortOrder),
                checksum: Value<String?>(media.checksumSha256),
                uploadState: Value<String>(media.uploadState.name),
                metadataJson: Value<String>(
                  jsonEncode(<String, Object?>{
                    'thumbnail_path': media.thumbnailPath,
                    'memory_version_id': media.memoryVersionId,
                    'mime_type': media.mimeType,
                    'byte_size': media.byteSize,
                    'pixel_width': media.pixelWidth,
                    'pixel_height': media.pixelHeight,
                    'duration_ms': media.duration?.inMilliseconds,
                    'is_cover': media.isCover,
                    'presentation_data': media.presentationData,
                    'created_at': media.createdAt.toIso8601String(),
                  }),
                ),
                createdAt: media.createdAt,
                updatedAt: media.updatedAt,
              ),
            );
      }
    });
  }

  @override
  Future<void> delete({
    required String accountId,
    required String draftId,
  }) async {
    await _database.transaction(() async {
      await (_database.delete(_database.localMediaReferences)..where(
            (LocalMediaReferences table) =>
                table.accountId.equals(accountId) &
                table.ownerDraftType.equals('memory') &
                table.ownerDraftId.equals(draftId),
          ))
          .go();
      await (_database.delete(_database.memoryDrafts)..where(
            (MemoryDrafts table) =>
                table.accountId.equals(accountId) & table.id.equals(draftId),
          ))
          .go();
    });
  }

  Map<String, Object?> _object(Object? value) {
    if (value is Map<String, Object?>) return value;
    if (value is Map) return value.cast<String, Object?>();
    return const <String, Object?>{};
  }

  MemoryMediaType _mediaType(String value) => MemoryMediaType.values.firstWhere(
    (MemoryMediaType item) => item.name == value,
  );

  MemoryMediaUploadState _uploadState(String value) =>
      MemoryMediaUploadState.values.firstWhere(
        (MemoryMediaUploadState item) => item.name == value,
        orElse: () => MemoryMediaUploadState.localSelected,
      );

  Duration? _duration(Object? value) =>
      value is int ? Duration(milliseconds: value) : null;
}
