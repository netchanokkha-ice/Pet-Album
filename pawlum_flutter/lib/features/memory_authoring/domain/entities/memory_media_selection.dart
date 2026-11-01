import 'memory_models.dart';

class MemoryMediaValidationLimits {
  const MemoryMediaValidationLimits({
    this.maxImages = 3,
    this.maxVideos = 1,
    this.maxImageBytes = 15 * 1024 * 1024,
    this.maxVideoBytes = 200 * 1024 * 1024,
    this.maxVideoDuration = const Duration(minutes: 3),
    this.maxZoom = 5,
    this.supportedImageMimeTypes = const <String>{
      'image/jpeg',
      'image/png',
      'image/webp',
      'image/heic',
      'image/heif',
    },
    this.supportedVideoMimeTypes = const <String>{
      'video/mp4',
      'video/quicktime',
      'video/webm',
    },
  });

  final int maxImages;
  final int maxVideos;
  final int maxImageBytes;
  final int maxVideoBytes;
  final Duration maxVideoDuration;
  final double maxZoom;
  final Set<String> supportedImageMimeTypes;
  final Set<String> supportedVideoMimeTypes;
}

class MemoryMediaCandidate {
  const MemoryMediaCandidate({
    required this.id,
    required this.sourcePath,
    required this.type,
    required this.mimeType,
    required this.byteSize,
    this.thumbnailPath,
    this.pixelWidth,
    this.pixelHeight,
    this.duration,
  });

  final String id;
  final String sourcePath;
  final MemoryMediaType type;
  final String mimeType;
  final int byteSize;
  final String? thumbnailPath;
  final int? pixelWidth;
  final int? pixelHeight;
  final Duration? duration;

  MemoryMediaCandidate withThumbnail(String? value) => MemoryMediaCandidate(
    id: id,
    sourcePath: sourcePath,
    type: type,
    mimeType: mimeType,
    byteSize: byteSize,
    thumbnailPath: value,
    pixelWidth: pixelWidth,
    pixelHeight: pixelHeight,
    duration: duration,
  );
}

abstract interface class MemoryMediaPicker {
  Future<List<MemoryMediaCandidate>> pickImages({required int maxCount});

  Future<MemoryMediaCandidate?> pickVideo({required Duration maxDuration});
}

abstract interface class MemoryThumbnailGenerator {
  Future<String?> createThumbnail(MemoryMediaCandidate candidate);
}

class ExistingMemoryThumbnailGenerator implements MemoryThumbnailGenerator {
  const ExistingMemoryThumbnailGenerator();

  @override
  Future<String?> createThumbnail(MemoryMediaCandidate candidate) async =>
      candidate.thumbnailPath ??
      (candidate.type == MemoryMediaType.image ? candidate.sourcePath : null);
}

class PickMemoryMedia {
  const PickMemoryMedia(this._picker, this._thumbnailGenerator);

  final MemoryMediaPicker _picker;
  final MemoryThumbnailGenerator _thumbnailGenerator;

  Future<MemoryMediaSelection> addImages({
    required MemoryMediaSelection selection,
    required String memoryVersionId,
    required DateTime at,
  }) async {
    final remaining = selection.limits.maxImages - selection.imageCount;
    if (remaining <= 0) {
      throw const MemoryValidationFailure(<MemoryValidationIssue>[
        MemoryValidationIssue.tooManyImages,
      ]);
    }
    final picked = await _picker.pickImages(maxCount: remaining);
    return selection.addCandidates(
      await _withThumbnails(picked),
      memoryVersionId: memoryVersionId,
      at: at,
    );
  }

  Future<MemoryMediaSelection> addVideo({
    required MemoryMediaSelection selection,
    required String memoryVersionId,
    required DateTime at,
  }) async {
    if (selection.videoCount >= selection.limits.maxVideos) {
      throw const MemoryValidationFailure(<MemoryValidationIssue>[
        MemoryValidationIssue.tooManyVideos,
      ]);
    }
    final picked = await _picker.pickVideo(
      maxDuration: selection.limits.maxVideoDuration,
    );
    if (picked == null) return selection;
    return selection.addCandidates(
      await _withThumbnails(<MemoryMediaCandidate>[picked]),
      memoryVersionId: memoryVersionId,
      at: at,
    );
  }

  Future<List<MemoryMediaCandidate>> _withThumbnails(
    List<MemoryMediaCandidate> candidates,
  ) async {
    return Future.wait(
      candidates.map((MemoryMediaCandidate candidate) async {
        final thumbnail = await _thumbnailGenerator.createThumbnail(candidate);
        return candidate.withThumbnail(thumbnail);
      }),
    );
  }
}

class MemoryMediaSelection {
  MemoryMediaSelection._({
    required this.limits,
    required List<MemoryMedia> media,
  }) : media = List<MemoryMedia>.unmodifiable(media);

  factory MemoryMediaSelection.empty({
    MemoryMediaValidationLimits limits = const MemoryMediaValidationLimits(),
  }) {
    return MemoryMediaSelection._(limits: limits, media: const <MemoryMedia>[]);
  }

  factory MemoryMediaSelection.fromMedia(
    List<MemoryMedia> media, {
    MemoryMediaValidationLimits limits = const MemoryMediaValidationLimits(),
  }) {
    return MemoryMediaSelection._(limits: limits, media: media);
  }

  final MemoryMediaValidationLimits limits;
  final List<MemoryMedia> media;

  List<MemoryMedia> get activeMedia => List<MemoryMedia>.unmodifiable(
    media.where(
      (MemoryMedia item) => item.uploadState != MemoryMediaUploadState.removed,
    ),
  );

  int get imageCount => activeMedia
      .where((MemoryMedia item) => item.type == MemoryMediaType.image)
      .length;

  int get videoCount => activeMedia
      .where((MemoryMedia item) => item.type == MemoryMediaType.video)
      .length;

  MemoryMediaSelection addCandidates(
    List<MemoryMediaCandidate> candidates, {
    required String memoryVersionId,
    required DateTime at,
  }) {
    final issues = <MemoryValidationIssue>[];
    final imageCandidates = candidates
        .where(
          (MemoryMediaCandidate item) => item.type == MemoryMediaType.image,
        )
        .length;
    final videoCandidates = candidates.length - imageCandidates;
    if (imageCount + imageCandidates > limits.maxImages) {
      issues.add(MemoryValidationIssue.tooManyImages);
    }
    if (videoCount + videoCandidates > limits.maxVideos) {
      issues.add(MemoryValidationIssue.tooManyVideos);
    }
    for (final candidate in candidates) {
      final mime = candidate.mimeType.toLowerCase();
      final supported = candidate.type == MemoryMediaType.image
          ? limits.supportedImageMimeTypes.contains(mime)
          : limits.supportedVideoMimeTypes.contains(mime);
      if (!supported) issues.add(MemoryValidationIssue.unsupportedMediaType);
      final maxBytes = candidate.type == MemoryMediaType.image
          ? limits.maxImageBytes
          : limits.maxVideoBytes;
      if (candidate.byteSize < 0 || candidate.byteSize > maxBytes) {
        issues.add(MemoryValidationIssue.mediaTooLarge);
      }
      if (candidate.type == MemoryMediaType.video &&
          candidate.duration != null &&
          candidate.duration! > limits.maxVideoDuration) {
        issues.add(MemoryValidationIssue.videoTooLong);
      }
    }
    if (issues.isNotEmpty) {
      throw MemoryValidationFailure(
        <MemoryValidationIssue>{...issues}.toList(),
      );
    }

    final active = activeMedia.toList();
    final additions = <MemoryMedia>[];
    for (var index = 0; index < candidates.length; index++) {
      final candidate = candidates[index];
      additions.add(
        MemoryMedia.create(
          id: candidate.id,
          memoryVersionId: memoryVersionId,
          sourcePath: candidate.sourcePath,
          thumbnailPath: candidate.thumbnailPath,
          type: candidate.type,
          sortOrder: active.length + index,
          isCover: active.isEmpty && index == 0,
          mimeType: candidate.mimeType,
          byteSize: candidate.byteSize,
          pixelWidth: candidate.pixelWidth,
          pixelHeight: candidate.pixelHeight,
          duration: candidate.duration,
          createdAt: at,
        ),
      );
    }
    final removed = media.where(
      (MemoryMedia item) => item.uploadState == MemoryMediaUploadState.removed,
    );
    return MemoryMediaSelection._(
      limits: limits,
      media: <MemoryMedia>[...active, ...additions, ...removed],
    );
  }

  MemoryMediaSelection chooseCover(String mediaId, DateTime at) {
    _requireActive(mediaId);
    return MemoryMediaSelection._(
      limits: limits,
      media: media
          .map(
            (MemoryMedia item) =>
                item.uploadState == MemoryMediaUploadState.removed
                ? item
                : item.updatePlacement(
                    sortOrder: item.sortOrder,
                    isCover: item.id == mediaId,
                    at: at,
                  ),
          )
          .toList(),
    );
  }

  MemoryMediaSelection reorder({
    required String mediaId,
    required int newIndex,
    required DateTime at,
  }) {
    final active = activeMedia.toList()
      ..sort(
        (MemoryMedia a, MemoryMedia b) => a.sortOrder.compareTo(b.sortOrder),
      );
    final oldIndex = active.indexWhere(
      (MemoryMedia item) => item.id == mediaId,
    );
    if (oldIndex < 0 || newIndex < 0 || newIndex >= active.length) {
      throw const MemoryValidationFailure(<MemoryValidationIssue>[
        MemoryValidationIssue.invalidMediaOrder,
      ]);
    }
    final moved = active.removeAt(oldIndex);
    active.insert(newIndex, moved);
    final reordered = <MemoryMedia>[
      for (var index = 0; index < active.length; index++)
        active[index].updatePlacement(
          sortOrder: index,
          isCover: active[index].isCover,
          at: at,
        ),
      ...media.where(
        (MemoryMedia item) =>
            item.uploadState == MemoryMediaUploadState.removed,
      ),
    ];
    return MemoryMediaSelection._(limits: limits, media: reordered);
  }

  MemoryMediaSelection updateFraming({
    required String mediaId,
    required MemoryMediaFraming framing,
    required DateTime at,
    String? thumbnailPath,
  }) {
    _requireActive(mediaId);
    return MemoryMediaSelection._(
      limits: limits,
      media: media
          .map(
            (MemoryMedia item) => item.id == mediaId
                ? item.updateFraming(
                    framing: framing,
                    at: at,
                    thumbnailPath: thumbnailPath,
                    maxZoom: limits.maxZoom,
                  )
                : item,
          )
          .toList(),
    );
  }

  MemoryMediaSelection remove(String mediaId, DateTime at) {
    _requireActive(mediaId);
    final changed = media
        .map((MemoryMedia item) => item.id == mediaId ? item.remove(at) : item)
        .toList();
    final active =
        changed
            .where(
              (MemoryMedia item) =>
                  item.uploadState != MemoryMediaUploadState.removed,
            )
            .toList()
          ..sort(
            (MemoryMedia a, MemoryMedia b) =>
                a.sortOrder.compareTo(b.sortOrder),
          );
    final hasCover = active.any((MemoryMedia item) => item.isCover);
    final normalized = <MemoryMedia>[
      for (var index = 0; index < active.length; index++)
        active[index].updatePlacement(
          sortOrder: index,
          isCover: hasCover ? active[index].isCover : index == 0,
          at: at,
        ),
      ...changed.where(
        (MemoryMedia item) =>
            item.uploadState == MemoryMediaUploadState.removed,
      ),
    ];
    return MemoryMediaSelection._(limits: limits, media: normalized);
  }

  void _requireActive(String mediaId) {
    if (!activeMedia.any((MemoryMedia item) => item.id == mediaId)) {
      throw const MemoryValidationFailure(<MemoryValidationIssue>[
        MemoryValidationIssue.mismatchedVersion,
      ]);
    }
  }
}
