enum MemoryLifecycleStatus {
  draft,
  publishing,
  published,
  publishFailed,
  softDeleted,
  purged,
}

enum MemoryVersionState { draft, editDraft, published, superseded }

enum MemoryPrivacy { onlyMe, petMembers, anyoneWithLink }

enum MemoryMediaType { image, video }

enum MemoryMediaUploadState {
  localSelected,
  queued,
  uploading,
  uploaded,
  failed,
  removed,
}

enum MemoryValidationIssue {
  petRequired,
  invalidVersionNumber,
  futureMemoryDate,
  blankTitle,
  invalidPresentationSchema,
  mediaRequired,
  tooManyImages,
  tooManyVideos,
  coverRequired,
  multipleCovers,
  mediaNotUploaded,
  invalidMediaPath,
  invalidMediaOrder,
  invalidMediaDimensions,
  invalidMediaDuration,
  invalidMediaChecksum,
  unsupportedMediaType,
  mediaTooLarge,
  videoTooLong,
  invalidCrop,
  invalidZoom,
  invalidPosition,
  mismatchedMemory,
  mismatchedVersion,
  invalidEditBase,
}

class MemoryMediaFraming {
  const MemoryMediaFraming({
    this.cropLeft = 0,
    this.cropTop = 0,
    this.cropWidth = 1,
    this.cropHeight = 1,
    this.zoom = 1,
    this.positionX = 0,
    this.positionY = 0,
  });

  final double cropLeft;
  final double cropTop;
  final double cropWidth;
  final double cropHeight;
  final double zoom;
  final double positionX;
  final double positionY;

  List<MemoryValidationIssue> validate({double maxZoom = 5}) {
    final issues = <MemoryValidationIssue>[];
    if (cropLeft < 0 ||
        cropTop < 0 ||
        cropWidth <= 0 ||
        cropHeight <= 0 ||
        cropLeft + cropWidth > 1 ||
        cropTop + cropHeight > 1) {
      issues.add(MemoryValidationIssue.invalidCrop);
    }
    if (zoom < 1 || zoom > maxZoom) {
      issues.add(MemoryValidationIssue.invalidZoom);
    }
    if (positionX < -1 || positionX > 1 || positionY < -1 || positionY > 1) {
      issues.add(MemoryValidationIssue.invalidPosition);
    }
    return List<MemoryValidationIssue>.unmodifiable(issues);
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'crop_left': cropLeft,
    'crop_top': cropTop,
    'crop_width': cropWidth,
    'crop_height': cropHeight,
    'zoom': zoom,
    'position_x': positionX,
    'position_y': positionY,
  };
}

class MemoryPresentation {
  MemoryPresentation({
    this.themeKey = 'pawlum_default',
    this.templateKey = 'classic',
    this.layoutKey = 'single',
    Map<String, Object?> decorationData = const <String, Object?>{},
    Map<String, Object?> layoutData = const <String, Object?>{},
    this.schemaVersion = 1,
  }) : decorationData = Map<String, Object?>.unmodifiable(decorationData),
       layoutData = Map<String, Object?>.unmodifiable(layoutData) {
    if (themeKey.trim().isEmpty ||
        templateKey.trim().isEmpty ||
        layoutKey.trim().isEmpty ||
        schemaVersion <= 0) {
      throw const MemoryValidationFailure(<MemoryValidationIssue>[
        MemoryValidationIssue.invalidPresentationSchema,
      ]);
    }
  }

  final String themeKey;
  final String templateKey;
  final String layoutKey;
  final Map<String, Object?> decorationData;
  final Map<String, Object?> layoutData;
  final int schemaVersion;
}

class MemoryMedia {
  MemoryMedia._({
    required this.id,
    required this.memoryVersionId,
    required this.sourcePath,
    required this.type,
    required this.sortOrder,
    required this.isCover,
    required this.uploadState,
    required this.createdAt,
    required this.updatedAt,
    required this.presentationData,
    this.thumbnailPath,
    this.mimeType,
    this.byteSize,
    this.pixelWidth,
    this.pixelHeight,
    this.duration,
    this.checksumSha256,
  });

  factory MemoryMedia.create({
    required String id,
    required String memoryVersionId,
    required String sourcePath,
    required MemoryMediaType type,
    required int sortOrder,
    required bool isCover,
    required DateTime createdAt,
    MemoryMediaUploadState uploadState = MemoryMediaUploadState.localSelected,
    String? thumbnailPath,
    String? mimeType,
    int? byteSize,
    int? pixelWidth,
    int? pixelHeight,
    Duration? duration,
    String? checksumSha256,
    Map<String, Object?> presentationData = const <String, Object?>{},
  }) {
    final issues = <MemoryValidationIssue>[];
    if (sourcePath.trim().isEmpty) {
      issues.add(MemoryValidationIssue.invalidMediaPath);
    }
    if (sortOrder < 0 || sortOrder > 3) {
      issues.add(MemoryValidationIssue.invalidMediaOrder);
    }
    if ((byteSize != null && byteSize < 0) ||
        (pixelWidth != null && pixelWidth <= 0) ||
        (pixelHeight != null && pixelHeight <= 0)) {
      issues.add(MemoryValidationIssue.invalidMediaDimensions);
    }
    if (duration != null && duration.isNegative) {
      issues.add(MemoryValidationIssue.invalidMediaDuration);
    }
    if (checksumSha256 != null &&
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(checksumSha256)) {
      issues.add(MemoryValidationIssue.invalidMediaChecksum);
    }
    if (issues.isNotEmpty) throw MemoryValidationFailure(issues);
    return MemoryMedia._(
      id: id,
      memoryVersionId: memoryVersionId,
      sourcePath: sourcePath.trim(),
      thumbnailPath: thumbnailPath,
      type: type,
      sortOrder: sortOrder,
      isCover: isCover,
      mimeType: mimeType,
      byteSize: byteSize,
      pixelWidth: pixelWidth,
      pixelHeight: pixelHeight,
      duration: duration,
      presentationData: Map<String, Object?>.unmodifiable(presentationData),
      uploadState: uploadState,
      checksumSha256: checksumSha256,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  final String id;
  final String memoryVersionId;
  final String sourcePath;
  final String? thumbnailPath;
  final MemoryMediaType type;
  final int sortOrder;
  final bool isCover;
  final String? mimeType;
  final int? byteSize;
  final int? pixelWidth;
  final int? pixelHeight;
  final Duration? duration;
  final Map<String, Object?> presentationData;
  final MemoryMediaUploadState uploadState;
  final String? checksumSha256;
  final DateTime createdAt;
  final DateTime updatedAt;

  MemoryMedia queue(DateTime at) => _transition(
    at: at,
    action: 'queue media',
    allowed: const <MemoryMediaUploadState>{
      MemoryMediaUploadState.localSelected,
      MemoryMediaUploadState.failed,
    },
    next: MemoryMediaUploadState.queued,
  );

  MemoryMedia startUpload(DateTime at) => _transition(
    at: at,
    action: 'start upload',
    allowed: const <MemoryMediaUploadState>{MemoryMediaUploadState.queued},
    next: MemoryMediaUploadState.uploading,
  );

  MemoryMedia markUploaded({required DateTime at, String? checksumSha256}) {
    final checksum = checksumSha256 ?? this.checksumSha256;
    if (checksum != null && !RegExp(r'^[0-9a-f]{64}$').hasMatch(checksum)) {
      throw const MemoryValidationFailure(<MemoryValidationIssue>[
        MemoryValidationIssue.invalidMediaChecksum,
      ]);
    }
    return _transition(
      at: at,
      action: 'complete upload',
      allowed: const <MemoryMediaUploadState>{MemoryMediaUploadState.uploading},
      next: MemoryMediaUploadState.uploaded,
      checksumSha256: checksum,
    );
  }

  MemoryMedia markFailed(DateTime at) => _transition(
    at: at,
    action: 'fail upload',
    allowed: const <MemoryMediaUploadState>{
      MemoryMediaUploadState.queued,
      MemoryMediaUploadState.uploading,
    },
    next: MemoryMediaUploadState.failed,
  );

  MemoryMedia remove(DateTime at) => _transition(
    at: at,
    action: 'remove media',
    allowed: const <MemoryMediaUploadState>{
      MemoryMediaUploadState.localSelected,
      MemoryMediaUploadState.queued,
      MemoryMediaUploadState.uploaded,
      MemoryMediaUploadState.failed,
    },
    next: MemoryMediaUploadState.removed,
  );

  MemoryMedia updatePlacement({
    required int sortOrder,
    required bool isCover,
    required DateTime at,
  }) {
    if (sortOrder < 0 || sortOrder > 3) {
      throw const MemoryValidationFailure(<MemoryValidationIssue>[
        MemoryValidationIssue.invalidMediaOrder,
      ]);
    }
    return _copy(at: at, sortOrder: sortOrder, isCover: isCover);
  }

  MemoryMedia updateFraming({
    required MemoryMediaFraming framing,
    required DateTime at,
    String? thumbnailPath,
    double maxZoom = 5,
  }) {
    final issues = framing.validate(maxZoom: maxZoom);
    if (issues.isNotEmpty) throw MemoryValidationFailure(issues);
    return _copy(
      at: at,
      presentationData: framing.toJson(),
      thumbnailPath: thumbnailPath,
    );
  }

  MemoryMedia _transition({
    required DateTime at,
    required String action,
    required Set<MemoryMediaUploadState> allowed,
    required MemoryMediaUploadState next,
    String? checksumSha256,
  }) {
    if (!allowed.contains(uploadState)) {
      throw MemoryInvalidTransitionFailure(
        from: uploadState.name,
        action: action,
      );
    }
    return _copy(
      at: at,
      uploadState: next,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
    );
  }

  MemoryMedia _copy({
    required DateTime at,
    int? sortOrder,
    bool? isCover,
    MemoryMediaUploadState? uploadState,
    String? checksumSha256,
    String? thumbnailPath,
    Map<String, Object?>? presentationData,
  }) {
    return MemoryMedia._(
      id: id,
      memoryVersionId: memoryVersionId,
      sourcePath: sourcePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      type: type,
      sortOrder: sortOrder ?? this.sortOrder,
      isCover: isCover ?? this.isCover,
      mimeType: mimeType,
      byteSize: byteSize,
      pixelWidth: pixelWidth,
      pixelHeight: pixelHeight,
      duration: duration,
      presentationData: presentationData ?? this.presentationData,
      uploadState: uploadState ?? this.uploadState,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
      createdAt: createdAt,
      updatedAt: at,
    );
  }
}

class MemoryVersion {
  MemoryVersion._({
    required this.id,
    required this.memoryId,
    required this.createdByAccountId,
    required this.versionNumber,
    required this.state,
    required this.memoryDate,
    required this.presentation,
    required this.media,
    required this.createdAt,
    required this.updatedAt,
    this.baseVersionId,
    this.title,
    this.caption,
    this.mood,
    this.location,
    this.occasion,
    this.publishedAt,
  });

  factory MemoryVersion.draft({
    required String id,
    required String memoryId,
    required String createdByAccountId,
    required int versionNumber,
    required DateTime memoryDate,
    required DateTime today,
    required DateTime createdAt,
    MemoryVersionState state = MemoryVersionState.draft,
    String? baseVersionId,
    String? title,
    String? caption,
    String? mood,
    String? location,
    String? occasion,
    MemoryPresentation? presentation,
    List<MemoryMedia> media = const <MemoryMedia>[],
  }) {
    final issues = <MemoryValidationIssue>[];
    if (versionNumber <= 0) {
      issues.add(MemoryValidationIssue.invalidVersionNumber);
    }
    if (_dateOnly(memoryDate).isAfter(_dateOnly(today))) {
      issues.add(MemoryValidationIssue.futureMemoryDate);
    }
    if (title != null && title.trim().isEmpty) {
      issues.add(MemoryValidationIssue.blankTitle);
    }
    if (state != MemoryVersionState.draft &&
        state != MemoryVersionState.editDraft) {
      throw MemoryInvalidTransitionFailure(
        from: state.name,
        action: 'create working version',
      );
    }
    if (state == MemoryVersionState.editDraft &&
        (baseVersionId == null || baseVersionId == id)) {
      issues.add(MemoryValidationIssue.invalidEditBase);
    }
    if (media.any((MemoryMedia item) => item.memoryVersionId != id)) {
      issues.add(MemoryValidationIssue.mismatchedVersion);
    }
    if (issues.isNotEmpty) throw MemoryValidationFailure(issues);
    return MemoryVersion._(
      id: id,
      memoryId: memoryId,
      createdByAccountId: createdByAccountId,
      baseVersionId: baseVersionId,
      versionNumber: versionNumber,
      state: state,
      title: title?.trim(),
      caption: caption,
      memoryDate: _dateOnly(memoryDate),
      mood: mood,
      location: location,
      occasion: occasion,
      presentation: presentation ?? MemoryPresentation(),
      media: List<MemoryMedia>.unmodifiable(media),
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  final String id;
  final String memoryId;
  final String createdByAccountId;
  final String? baseVersionId;
  final int versionNumber;
  final MemoryVersionState state;
  final String? title;
  final String? caption;
  final DateTime memoryDate;
  final String? mood;
  final String? location;
  final String? occasion;
  final MemoryPresentation presentation;
  final List<MemoryMedia> media;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  List<MemoryValidationIssue> publicationIssues() {
    final activeMedia = media
        .where(
          (MemoryMedia item) =>
              item.uploadState != MemoryMediaUploadState.removed,
        )
        .toList(growable: false);
    final issues = <MemoryValidationIssue>[];
    if (activeMedia.isEmpty) issues.add(MemoryValidationIssue.mediaRequired);
    if (activeMedia
            .where((MemoryMedia item) => item.type == MemoryMediaType.image)
            .length >
        3) {
      issues.add(MemoryValidationIssue.tooManyImages);
    }
    if (activeMedia
            .where((MemoryMedia item) => item.type == MemoryMediaType.video)
            .length >
        1) {
      issues.add(MemoryValidationIssue.tooManyVideos);
    }
    final coverCount = activeMedia
        .where((MemoryMedia item) => item.isCover)
        .length;
    if (activeMedia.isNotEmpty && coverCount == 0) {
      issues.add(MemoryValidationIssue.coverRequired);
    } else if (coverCount > 1) {
      issues.add(MemoryValidationIssue.multipleCovers);
    }
    if (activeMedia.any(
      (MemoryMedia item) => item.uploadState != MemoryMediaUploadState.uploaded,
    )) {
      issues.add(MemoryValidationIssue.mediaNotUploaded);
    }
    return List<MemoryValidationIssue>.unmodifiable(issues);
  }

  MemoryVersion publish(DateTime at) {
    if (state != MemoryVersionState.draft &&
        state != MemoryVersionState.editDraft) {
      throw MemoryInvalidTransitionFailure(
        from: state.name,
        action: 'publish version',
      );
    }
    final issues = publicationIssues();
    if (issues.isNotEmpty) throw MemoryValidationFailure(issues);
    return _copy(state: MemoryVersionState.published, at: at, publishedAt: at);
  }

  MemoryVersion supersede(DateTime at) {
    if (state != MemoryVersionState.published) {
      throw MemoryInvalidTransitionFailure(
        from: state.name,
        action: 'supersede version',
      );
    }
    return _copy(state: MemoryVersionState.superseded, at: at);
  }

  MemoryVersion _copy({
    required MemoryVersionState state,
    required DateTime at,
    DateTime? publishedAt,
  }) {
    return MemoryVersion._(
      id: id,
      memoryId: memoryId,
      createdByAccountId: createdByAccountId,
      baseVersionId: baseVersionId,
      versionNumber: versionNumber,
      state: state,
      title: title,
      caption: caption,
      memoryDate: memoryDate,
      mood: mood,
      location: location,
      occasion: occasion,
      presentation: presentation,
      media: media,
      createdAt: createdAt,
      updatedAt: at,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}

class MemoryAggregate {
  MemoryAggregate._({
    required this.id,
    required this.creatorAccountId,
    required this.petIds,
    required this.lifecycleStatus,
    required this.privacy,
    required this.isFirstMemory,
    required this.createdAt,
    required this.updatedAt,
    required this.versionHistory,
    this.currentPublishedVersion,
    this.currentWorkingVersion,
    this.publishedAt,
    this.deletedAt,
    this.deletionExpiresAt,
    this.purgedAt,
    this.preDeletionStatus,
  });

  factory MemoryAggregate.draft({
    required String id,
    required String creatorAccountId,
    required Set<String> petIds,
    required MemoryVersion workingVersion,
    required DateTime createdAt,
    MemoryPrivacy privacy = MemoryPrivacy.onlyMe,
    bool isFirstMemory = false,
  }) {
    final issues = <MemoryValidationIssue>[];
    if (petIds.isEmpty) issues.add(MemoryValidationIssue.petRequired);
    if (workingVersion.memoryId != id) {
      issues.add(MemoryValidationIssue.mismatchedMemory);
    }
    if (workingVersion.state != MemoryVersionState.draft) {
      throw MemoryInvalidTransitionFailure(
        from: workingVersion.state.name,
        action: 'create memory draft',
      );
    }
    if (issues.isNotEmpty) throw MemoryValidationFailure(issues);
    return MemoryAggregate._(
      id: id,
      creatorAccountId: creatorAccountId,
      petIds: Set<String>.unmodifiable(petIds),
      lifecycleStatus: MemoryLifecycleStatus.draft,
      privacy: privacy,
      isFirstMemory: isFirstMemory,
      currentWorkingVersion: workingVersion,
      versionHistory: const <MemoryVersion>[],
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  final String id;
  final String creatorAccountId;
  final Set<String> petIds;
  final MemoryLifecycleStatus lifecycleStatus;
  final MemoryPrivacy privacy;
  final bool isFirstMemory;
  final MemoryVersion? currentPublishedVersion;
  final MemoryVersion? currentWorkingVersion;
  final List<MemoryVersion> versionHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final DateTime? deletedAt;
  final DateTime? deletionExpiresAt;
  final DateTime? purgedAt;
  final MemoryLifecycleStatus? preDeletionStatus;

  MemoryAggregate beginPublishing(DateTime at) {
    _requireLifecycle(const <MemoryLifecycleStatus>{
      MemoryLifecycleStatus.draft,
      MemoryLifecycleStatus.publishFailed,
    }, 'begin publishing');
    final working = currentWorkingVersion;
    if (working == null) {
      throw const MemoryValidationFailure(<MemoryValidationIssue>[
        MemoryValidationIssue.mismatchedVersion,
      ]);
    }
    final issues = working.publicationIssues();
    if (issues.isNotEmpty) throw MemoryValidationFailure(issues);
    return _copy(lifecycleStatus: MemoryLifecycleStatus.publishing, at: at);
  }

  MemoryAggregate markPublishFailed(DateTime at) {
    _requireLifecycle(const <MemoryLifecycleStatus>{
      MemoryLifecycleStatus.publishing,
    }, 'mark publish failed');
    return _copy(lifecycleStatus: MemoryLifecycleStatus.publishFailed, at: at);
  }

  MemoryAggregate publish(DateTime at) {
    _requireLifecycle(const <MemoryLifecycleStatus>{
      MemoryLifecycleStatus.publishing,
    }, 'publish memory');
    final published = currentWorkingVersion!.publish(at);
    return _copy(
      lifecycleStatus: MemoryLifecycleStatus.published,
      at: at,
      publishedAt: at,
      publishedVersion: published,
      clearWorkingVersion: true,
    );
  }

  MemoryAggregate beginEditDraft({
    required MemoryVersion editDraft,
    required DateTime at,
  }) {
    _requireLifecycle(const <MemoryLifecycleStatus>{
      MemoryLifecycleStatus.published,
    }, 'begin edit draft');
    final published = currentPublishedVersion!;
    if (currentWorkingVersion != null ||
        editDraft.memoryId != id ||
        editDraft.state != MemoryVersionState.editDraft ||
        editDraft.baseVersionId != published.id) {
      throw const MemoryValidationFailure(<MemoryValidationIssue>[
        MemoryValidationIssue.invalidEditBase,
      ]);
    }
    return _copy(at: at, workingVersion: editDraft);
  }

  MemoryAggregate promoteEditDraft(DateTime at) {
    _requireLifecycle(const <MemoryLifecycleStatus>{
      MemoryLifecycleStatus.published,
    }, 'promote edit draft');
    final working = currentWorkingVersion;
    final published = currentPublishedVersion;
    if (working == null ||
        published == null ||
        working.state != MemoryVersionState.editDraft) {
      throw const MemoryValidationFailure(<MemoryValidationIssue>[
        MemoryValidationIssue.invalidEditBase,
      ]);
    }
    final promoted = working.publish(at);
    final superseded = published.supersede(at);
    return _copy(
      at: at,
      publishedAt: at,
      publishedVersion: promoted,
      versionHistory: <MemoryVersion>[...versionHistory, superseded],
      clearWorkingVersion: true,
    );
  }

  MemoryAggregate softDelete(DateTime at) {
    _requireLifecycle(const <MemoryLifecycleStatus>{
      MemoryLifecycleStatus.draft,
      MemoryLifecycleStatus.publishing,
      MemoryLifecycleStatus.published,
      MemoryLifecycleStatus.publishFailed,
    }, 'soft delete memory');
    return _copy(
      lifecycleStatus: MemoryLifecycleStatus.softDeleted,
      at: at,
      deletedAt: at,
      deletionExpiresAt: at.add(const Duration(days: 7)),
      preDeletionStatus: lifecycleStatus,
    );
  }

  MemoryAggregate restore(DateTime at) {
    _requireLifecycle(const <MemoryLifecycleStatus>{
      MemoryLifecycleStatus.softDeleted,
    }, 'restore memory');
    final expiresAt = deletionExpiresAt;
    if (expiresAt == null || !at.isBefore(expiresAt)) {
      throw const MemoryDeletionExpiredFailure();
    }
    return _copy(
      lifecycleStatus: preDeletionStatus!,
      at: at,
      clearDeletion: true,
    );
  }

  MemoryAggregate purge(DateTime at) {
    _requireLifecycle(const <MemoryLifecycleStatus>{
      MemoryLifecycleStatus.softDeleted,
    }, 'purge memory');
    if (deletionExpiresAt == null || at.isBefore(deletionExpiresAt!)) {
      throw const MemoryDeletionNotExpiredFailure();
    }
    return _copy(
      lifecycleStatus: MemoryLifecycleStatus.purged,
      at: at,
      purgedAt: at,
    );
  }

  void _requireLifecycle(Set<MemoryLifecycleStatus> allowed, String action) {
    if (!allowed.contains(lifecycleStatus)) {
      throw MemoryInvalidTransitionFailure(
        from: lifecycleStatus.name,
        action: action,
      );
    }
  }

  MemoryAggregate _copy({
    required DateTime at,
    MemoryLifecycleStatus? lifecycleStatus,
    MemoryVersion? publishedVersion,
    MemoryVersion? workingVersion,
    List<MemoryVersion>? versionHistory,
    bool clearWorkingVersion = false,
    DateTime? publishedAt,
    DateTime? deletedAt,
    DateTime? deletionExpiresAt,
    DateTime? purgedAt,
    MemoryLifecycleStatus? preDeletionStatus,
    bool clearDeletion = false,
  }) {
    return MemoryAggregate._(
      id: id,
      creatorAccountId: creatorAccountId,
      petIds: petIds,
      lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
      privacy: privacy,
      isFirstMemory: isFirstMemory,
      currentPublishedVersion: publishedVersion ?? currentPublishedVersion,
      currentWorkingVersion: clearWorkingVersion
          ? null
          : workingVersion ?? currentWorkingVersion,
      versionHistory: List<MemoryVersion>.unmodifiable(
        versionHistory ?? this.versionHistory,
      ),
      createdAt: createdAt,
      updatedAt: at,
      publishedAt: publishedAt ?? this.publishedAt,
      deletedAt: clearDeletion ? null : deletedAt ?? this.deletedAt,
      deletionExpiresAt: clearDeletion
          ? null
          : deletionExpiresAt ?? this.deletionExpiresAt,
      purgedAt: purgedAt ?? this.purgedAt,
      preDeletionStatus: clearDeletion
          ? null
          : preDeletionStatus ?? this.preDeletionStatus,
    );
  }
}

sealed class MemoryDomainFailure implements Exception {
  const MemoryDomainFailure();
}

class MemoryValidationFailure extends MemoryDomainFailure {
  const MemoryValidationFailure(this.issues);

  final List<MemoryValidationIssue> issues;
}

class MemoryInvalidTransitionFailure extends MemoryDomainFailure {
  const MemoryInvalidTransitionFailure({
    required this.from,
    required this.action,
  });

  final String from;
  final String action;
}

class MemoryDeletionExpiredFailure extends MemoryDomainFailure {
  const MemoryDeletionExpiredFailure();
}

class MemoryDeletionNotExpiredFailure extends MemoryDomainFailure {
  const MemoryDeletionNotExpiredFailure();
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
