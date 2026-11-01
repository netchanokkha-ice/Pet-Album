import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_media_selection.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_models.dart';

void main() {
  final now = DateTime.utc(2026, 11, 1, 10);

  test(
    'valid mixed media supports thumbnails, cover, order, and framing',
    () async {
      final picker = _FakeMediaPicker(
        images: <MemoryMediaCandidate>[
          _candidate('image-1', MemoryMediaType.image),
          _candidate('image-2', MemoryMediaType.image),
          _candidate('image-3', MemoryMediaType.image),
        ],
        video: _candidate(
          'video-1',
          MemoryMediaType.video,
          duration: const Duration(seconds: 20),
        ),
      );
      final pick = PickMemoryMedia(picker, const _FakeThumbnailGenerator());

      var selection = MemoryMediaSelection.empty();
      selection = await pick.addImages(
        selection: selection,
        memoryVersionId: 'version-1',
        at: now,
      );
      selection = await pick.addVideo(
        selection: selection,
        memoryVersionId: 'version-1',
        at: now.add(const Duration(seconds: 1)),
      );

      expect(selection.imageCount, 3);
      expect(selection.videoCount, 1);
      expect(
        selection.activeMedia.map((MemoryMedia item) => item.sortOrder),
        <int>[0, 1, 2, 3],
      );
      expect(
        selection.activeMedia.singleWhere((item) => item.isCover).id,
        'image-1',
      );
      expect(selection.activeMedia.first.thumbnailPath, '/thumbs/image-1.jpg');
      expect(picker.lastImageLimit, 3);

      selection = selection.chooseCover('video-1', now);
      selection = selection.reorder(mediaId: 'video-1', newIndex: 0, at: now);
      selection = selection.updateFraming(
        mediaId: 'image-2',
        framing: const MemoryMediaFraming(
          cropLeft: 0.1,
          cropTop: 0.1,
          cropWidth: 0.8,
          cropHeight: 0.8,
          zoom: 1.5,
          positionX: 0.25,
          positionY: -0.2,
        ),
        thumbnailPath: '/thumbs/image-2-cropped.jpg',
        at: now,
      );

      expect(selection.activeMedia.first.id, 'video-1');
      expect(selection.activeMedia.first.isCover, isTrue);
      final framed = selection.activeMedia.singleWhere(
        (MemoryMedia item) => item.id == 'image-2',
      );
      expect(framed.presentationData['zoom'], 1.5);
      expect(framed.presentationData['position_y'], -0.2);
      expect(framed.thumbnailPath, '/thumbs/image-2-cropped.jpg');
    },
  );

  test('selection rejects excess images and videos atomically', () {
    final selection = MemoryMediaSelection.empty();
    expect(
      () => selection.addCandidates(
        <MemoryMediaCandidate>[
          for (var index = 0; index < 4; index++)
            _candidate('image-$index', MemoryMediaType.image),
        ],
        memoryVersionId: 'version-1',
        at: now,
      ),
      throwsA(
        isA<MemoryValidationFailure>().having(
          (MemoryValidationFailure failure) => failure.issues,
          'issues',
          contains(MemoryValidationIssue.tooManyImages),
        ),
      ),
    );
    expect(
      () => selection.addCandidates(
        <MemoryMediaCandidate>[
          _candidate('video-1', MemoryMediaType.video),
          _candidate('video-2', MemoryMediaType.video),
        ],
        memoryVersionId: 'version-1',
        at: now,
      ),
      throwsA(
        isA<MemoryValidationFailure>().having(
          (MemoryValidationFailure failure) => failure.issues,
          'issues',
          contains(MemoryValidationIssue.tooManyVideos),
        ),
      ),
    );
    expect(selection.activeMedia, isEmpty);
  });

  test('unsupported, oversized, and overlong files report exact limits', () {
    const limits = MemoryMediaValidationLimits(
      maxImageBytes: 100,
      maxVideoBytes: 1000,
      maxVideoDuration: Duration(seconds: 10),
    );
    final selection = MemoryMediaSelection.empty(limits: limits);

    expect(
      () => selection.addCandidates(
        const <MemoryMediaCandidate>[
          MemoryMediaCandidate(
            id: 'bad-image',
            sourcePath: '/private/photo.gif',
            type: MemoryMediaType.image,
            mimeType: 'image/gif',
            byteSize: 101,
          ),
          MemoryMediaCandidate(
            id: 'long-video',
            sourcePath: '/private/movie.mp4',
            type: MemoryMediaType.video,
            mimeType: 'video/mp4',
            byteSize: 1000,
            duration: Duration(seconds: 11),
          ),
        ],
        memoryVersionId: 'version-1',
        at: now,
      ),
      throwsA(
        isA<MemoryValidationFailure>().having(
          (MemoryValidationFailure failure) => failure.issues,
          'issues',
          containsAll(<MemoryValidationIssue>[
            MemoryValidationIssue.unsupportedMediaType,
            MemoryValidationIssue.mediaTooLarge,
            MemoryValidationIssue.videoTooLong,
          ]),
        ),
      ),
    );
  });

  test('invalid crop, zoom, and position metadata is denied', () {
    var selection = MemoryMediaSelection.empty();
    selection = selection.addCandidates(
      <MemoryMediaCandidate>[_candidate('image-1', MemoryMediaType.image)],
      memoryVersionId: 'version-1',
      at: now,
    );

    expect(
      () => selection.updateFraming(
        mediaId: 'image-1',
        framing: const MemoryMediaFraming(
          cropLeft: 0.8,
          cropWidth: 0.5,
          zoom: 8,
          positionX: 2,
        ),
        at: now,
      ),
      throwsA(
        isA<MemoryValidationFailure>().having(
          (MemoryValidationFailure failure) => failure.issues,
          'issues',
          containsAll(<MemoryValidationIssue>[
            MemoryValidationIssue.invalidCrop,
            MemoryValidationIssue.invalidZoom,
            MemoryValidationIssue.invalidPosition,
          ]),
        ),
      ),
    );
  });

  test('publication remains denied when no media has been selected', () {
    final version = MemoryVersion.draft(
      id: 'version-1',
      memoryId: 'memory-1',
      createdByAccountId: 'account-1',
      versionNumber: 1,
      memoryDate: now,
      today: now,
      createdAt: now,
    );
    final memory = MemoryAggregate.draft(
      id: 'memory-1',
      creatorAccountId: 'account-1',
      petIds: const <String>{'pet-1'},
      workingVersion: version,
      createdAt: now,
    );

    expect(
      () => memory.beginPublishing(now),
      throwsA(
        isA<MemoryValidationFailure>().having(
          (MemoryValidationFailure failure) => failure.issues,
          'issues',
          contains(MemoryValidationIssue.mediaRequired),
        ),
      ),
    );
  });
}

MemoryMediaCandidate _candidate(
  String id,
  MemoryMediaType type, {
  Duration? duration,
}) {
  return MemoryMediaCandidate(
    id: id,
    sourcePath: '/private/$id.${type == MemoryMediaType.image ? 'jpg' : 'mp4'}',
    type: type,
    mimeType: type == MemoryMediaType.image ? 'image/jpeg' : 'video/mp4',
    byteSize: 100,
    duration: duration,
  );
}

class _FakeMediaPicker implements MemoryMediaPicker {
  _FakeMediaPicker({required this.images, required this.video});

  final List<MemoryMediaCandidate> images;
  final MemoryMediaCandidate? video;
  int? lastImageLimit;

  @override
  Future<List<MemoryMediaCandidate>> pickImages({required int maxCount}) async {
    lastImageLimit = maxCount;
    return images.take(maxCount).toList();
  }

  @override
  Future<MemoryMediaCandidate?> pickVideo({
    required Duration maxDuration,
  }) async => video;
}

class _FakeThumbnailGenerator implements MemoryThumbnailGenerator {
  const _FakeThumbnailGenerator();

  @override
  Future<String?> createThumbnail(MemoryMediaCandidate candidate) async =>
      '/thumbs/${candidate.id}.jpg';
}
