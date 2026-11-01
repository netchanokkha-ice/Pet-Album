import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_models.dart';

void main() {
  final now = DateTime.utc(2026, 11, 1, 10);

  test('new draft uses private scrapbook defaults and remains incomplete', () {
    final version = _draftVersion(now: now, media: const <MemoryMedia>[]);
    final memory = _draftMemory(now: now, version: version);

    expect(memory.lifecycleStatus, MemoryLifecycleStatus.draft);
    expect(memory.privacy, MemoryPrivacy.onlyMe);
    expect(version.state, MemoryVersionState.draft);
    expect(version.presentation.themeKey, 'pawlum_default');
    expect(version.presentation.templateKey, 'classic');
    expect(version.presentation.layoutKey, 'single');
    expect(
      () => memory.beginPublishing(now.add(const Duration(minutes: 1))),
      throwsA(
        isA<MemoryValidationFailure>().having(
          (MemoryValidationFailure failure) => failure.issues,
          'issues',
          contains(MemoryValidationIssue.mediaRequired),
        ),
      ),
    );
  });

  test(
    'draft transitions through publishing to one stable published version',
    () {
      final version = _draftVersion(now: now);
      final draft = _draftMemory(now: now, version: version);

      final publishing = draft.beginPublishing(
        now.add(const Duration(minutes: 1)),
      );
      final published = publishing.publish(now.add(const Duration(minutes: 2)));

      expect(publishing.lifecycleStatus, MemoryLifecycleStatus.publishing);
      expect(published.lifecycleStatus, MemoryLifecycleStatus.published);
      expect(published.currentWorkingVersion, isNull);
      expect(published.currentPublishedVersion?.id, version.id);
      expect(
        published.currentPublishedVersion?.state,
        MemoryVersionState.published,
      );
      expect(published.publishedAt, now.add(const Duration(minutes: 2)));
    },
  );

  test('publish failure keeps the draft recoverable for a valid retry', () {
    final draft = _draftMemory(
      now: now,
      version: _draftVersion(now: now),
    );
    final publishing = draft.beginPublishing(
      now.add(const Duration(minutes: 1)),
    );
    final failed = publishing.markPublishFailed(
      now.add(const Duration(minutes: 2)),
    );

    expect(failed.lifecycleStatus, MemoryLifecycleStatus.publishFailed);
    expect(failed.currentWorkingVersion?.state, MemoryVersionState.draft);

    final retried = failed
        .beginPublishing(now.add(const Duration(minutes: 3)))
        .publish(now.add(const Duration(minutes: 4)));
    expect(retried.lifecycleStatus, MemoryLifecycleStatus.published);
    expect(retried.currentPublishedVersion?.id, 'version-1');
  });

  test('edit draft preserves published content until promotion succeeds', () {
    final published = _publishedMemory(now);
    final stableVersion = published.currentPublishedVersion!;
    final editDraft = _draftVersion(
      now: now.add(const Duration(hours: 1)),
      id: 'version-2',
      versionNumber: 2,
      state: MemoryVersionState.editDraft,
      baseVersionId: stableVersion.id,
    );

    final editing = published.beginEditDraft(
      editDraft: editDraft,
      at: now.add(const Duration(hours: 1)),
    );
    expect(editing.currentPublishedVersion?.id, stableVersion.id);
    expect(
      editing.currentPublishedVersion?.state,
      MemoryVersionState.published,
    );
    expect(editing.currentWorkingVersion?.state, MemoryVersionState.editDraft);

    final promoted = editing.promoteEditDraft(
      now.add(const Duration(hours: 2)),
    );
    expect(promoted.currentPublishedVersion?.id, 'version-2');
    expect(promoted.currentWorkingVersion, isNull);
    expect(promoted.versionHistory.single.id, stableVersion.id);
    expect(promoted.versionHistory.single.state, MemoryVersionState.superseded);
  });

  test('media upload states are explicit and reject invalid transitions', () {
    final selected = MemoryMedia.create(
      id: 'media-1',
      memoryVersionId: 'version-1',
      sourcePath: '/private/photo.jpg',
      type: MemoryMediaType.image,
      sortOrder: 0,
      isCover: true,
      createdAt: now,
    );
    final failed = selected
        .queue(now.add(const Duration(seconds: 1)))
        .startUpload(now.add(const Duration(seconds: 2)))
        .markFailed(now.add(const Duration(seconds: 3)));
    final uploaded = failed
        .queue(now.add(const Duration(seconds: 4)))
        .startUpload(now.add(const Duration(seconds: 5)))
        .markUploaded(
          at: now.add(const Duration(seconds: 6)),
          checksumSha256: List<String>.filled(64, 'a').join(),
        );

    expect(uploaded.uploadState, MemoryMediaUploadState.uploaded);
    expect(
      () => uploaded.markUploaded(at: now.add(const Duration(seconds: 7))),
      throwsA(isA<MemoryInvalidTransitionFailure>()),
    );
    expect(
      () => MemoryMedia.create(
        id: 'bad-media',
        memoryVersionId: 'version-1',
        sourcePath: ' ',
        type: MemoryMediaType.image,
        sortOrder: 4,
        isCover: false,
        createdAt: now,
      ),
      throwsA(
        isA<MemoryValidationFailure>().having(
          (MemoryValidationFailure failure) => failure.issues,
          'issues',
          containsAll(<MemoryValidationIssue>[
            MemoryValidationIssue.invalidMediaPath,
            MemoryValidationIssue.invalidMediaOrder,
          ]),
        ),
      ),
    );
  });

  test('soft delete restores the prior published lifecycle before expiry', () {
    final published = _publishedMemory(now);
    final deletedAt = now.add(const Duration(days: 1));
    final deleted = published.softDelete(deletedAt);

    expect(deleted.lifecycleStatus, MemoryLifecycleStatus.softDeleted);
    expect(deleted.preDeletionStatus, MemoryLifecycleStatus.published);
    expect(deleted.deletionExpiresAt, deletedAt.add(const Duration(days: 7)));

    final restored = deleted.restore(deletedAt.add(const Duration(days: 6)));
    expect(restored.lifecycleStatus, MemoryLifecycleStatus.published);
    expect(restored.currentPublishedVersion?.id, 'version-1');
    expect(restored.deletedAt, isNull);
    expect(restored.deletionExpiresAt, isNull);
    expect(restored.preDeletionStatus, isNull);
  });

  test('expired deletion cannot restore and becomes eligible for purge', () {
    final deleted = _publishedMemory(now).softDelete(now);

    expect(
      () => deleted.restore(now.add(const Duration(days: 7))),
      throwsA(isA<MemoryDeletionExpiredFailure>()),
    );
    expect(
      () => deleted.purge(now.add(const Duration(days: 6))),
      throwsA(isA<MemoryDeletionNotExpiredFailure>()),
    );
    final purged = deleted.purge(now.add(const Duration(days: 7)));
    expect(purged.lifecycleStatus, MemoryLifecycleStatus.purged);
    expect(purged.purgedAt, now.add(const Duration(days: 7)));
    expect(
      () => purged.restore(now.add(const Duration(days: 7))),
      throwsA(isA<MemoryInvalidTransitionFailure>()),
    );
  });

  test('invalid aggregate and version transitions are rejected', () {
    final draft = _draftMemory(
      now: now,
      version: _draftVersion(now: now),
    );
    expect(
      () => draft.publish(now.add(const Duration(minutes: 1))),
      throwsA(isA<MemoryInvalidTransitionFailure>()),
    );

    final published = _publishedMemory(now);
    expect(
      () => published.beginPublishing(now.add(const Duration(hours: 1))),
      throwsA(isA<MemoryInvalidTransitionFailure>()),
    );
    expect(
      () => MemoryAggregate.draft(
        id: 'memory-1',
        creatorAccountId: 'account-1',
        petIds: const <String>{},
        workingVersion: _draftVersion(now: now),
        createdAt: now,
      ),
      throwsA(
        isA<MemoryValidationFailure>().having(
          (MemoryValidationFailure failure) => failure.issues,
          'issues',
          contains(MemoryValidationIssue.petRequired),
        ),
      ),
    );
  });
}

MemoryAggregate _publishedMemory(DateTime now) {
  return _draftMemory(
        now: now,
        version: _draftVersion(now: now),
      )
      .beginPublishing(now.add(const Duration(minutes: 1)))
      .publish(now.add(const Duration(minutes: 2)));
}

MemoryAggregate _draftMemory({
  required DateTime now,
  required MemoryVersion version,
}) {
  return MemoryAggregate.draft(
    id: 'memory-1',
    creatorAccountId: 'account-1',
    petIds: const <String>{'pet-1'},
    workingVersion: version,
    createdAt: now,
  );
}

MemoryVersion _draftVersion({
  required DateTime now,
  String id = 'version-1',
  int versionNumber = 1,
  MemoryVersionState state = MemoryVersionState.draft,
  String? baseVersionId,
  List<MemoryMedia>? media,
}) {
  return MemoryVersion.draft(
    id: id,
    memoryId: 'memory-1',
    createdByAccountId: 'account-1',
    versionNumber: versionNumber,
    state: state,
    baseVersionId: baseVersionId,
    title: 'A sunny afternoon',
    caption: 'Mochi found the warmest patch of light.',
    memoryDate: DateTime.utc(2026, 10, 31),
    today: now,
    createdAt: now,
    media: media ?? <MemoryMedia>[_uploadedMedia(id, now)],
  );
}

MemoryMedia _uploadedMedia(String versionId, DateTime now) {
  return MemoryMedia.create(
        id: 'media-$versionId',
        memoryVersionId: versionId,
        sourcePath: '/private/$versionId.jpg',
        type: MemoryMediaType.image,
        sortOrder: 0,
        isCover: true,
        createdAt: now,
      )
      .queue(now.add(const Duration(seconds: 1)))
      .startUpload(now.add(const Duration(seconds: 2)))
      .markUploaded(at: now.add(const Duration(seconds: 3)));
}
