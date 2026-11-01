import 'dart:async';

import 'package:get/get.dart';

import '../../domain/entities/memory_authoring_draft.dart';
import '../../domain/entities/memory_media_selection.dart';
import '../../domain/entities/memory_models.dart';
import '../../domain/repositories/memory_authoring_draft_repository.dart';

enum MemoryAuthoringStep { media, decoration, story, review }

class MemoryAuthoringController extends GetxController {
  MemoryAuthoringController({
    required MemoryMediaPicker picker,
    required this.now,
    MemoryAuthoringDraftRepository? draftRepository,
    this.accountId = 'local-account',
    this.draftId = 'new-memory-draft',
    this.memoryId = 'local-memory',
    this.onExit,
    MemoryMediaValidationLimits limits = const MemoryMediaValidationLimits(),
  }) : _draftRepository =
           draftRepository ?? const _NoopMemoryAuthoringDraftRepository(),
       _pickMedia = PickMemoryMedia(
         picker,
         const ExistingMemoryThumbnailGenerator(),
       ),
       mediaSelection = MemoryMediaSelection.empty(limits: limits).obs,
       memoryDate = _dateOnly(now()).obs,
       _createdAt = now();

  final PickMemoryMedia _pickMedia;
  final MemoryAuthoringDraftRepository _draftRepository;
  final DateTime Function() now;
  final String accountId;
  String draftId;
  String memoryId;
  final Future<void> Function()? onExit;
  DateTime _createdAt;
  Timer? _autosaveTimer;
  Future<void>? _saveInFlight;
  bool _saveRequested = false;

  final step = MemoryAuthoringStep.media.obs;
  final Rx<MemoryMediaSelection> mediaSelection;
  final isPicking = false.obs;
  final isLoadingDraft = true.obs;
  final isSavingDraft = false.obs;
  final hasUnsavedChanges = false.obs;
  final pendingSync = false.obs;
  final errorMessage = RxnString();
  final title = ''.obs;
  final caption = ''.obs;
  final mood = ''.obs;
  final location = ''.obs;
  final occasion = ''.obs;
  final Rx<DateTime> memoryDate;
  final themeKey = 'pawlum_default'.obs;
  final templateKey = 'classic'.obs;
  final layoutKey = 'single'.obs;

  @override
  void onReady() {
    super.onReady();
    unawaited(loadDraft());
  }

  @override
  void onClose() {
    _autosaveTimer?.cancel();
    super.onClose();
  }

  MemoryPresentation get presentation => MemoryPresentation(
    themeKey: themeKey.value,
    templateKey: templateKey.value,
    layoutKey: layoutKey.value,
  );

  Future<void> addImages() async {
    await _pick(
      () => _pickMedia.addImages(
        selection: mediaSelection.value,
        memoryVersionId: 'local-working-version',
        at: now(),
      ),
    );
  }

  Future<void> addVideo() async {
    await _pick(
      () => _pickMedia.addVideo(
        selection: mediaSelection.value,
        memoryVersionId: 'local-working-version',
        at: now(),
      ),
    );
  }

  Future<void> _pick(Future<MemoryMediaSelection> Function() operation) async {
    if (isPicking.value) return;
    isPicking.value = true;
    errorMessage.value = null;
    try {
      mediaSelection.value = await operation();
      _markChanged();
    } on MemoryValidationFailure catch (failure) {
      errorMessage.value = _validationMessage(failure.issues);
    } on Object {
      errorMessage.value = 'We could not add that media. Please try again.';
    } finally {
      isPicking.value = false;
    }
  }

  void chooseCover(String mediaId) {
    mediaSelection.value = mediaSelection.value.chooseCover(mediaId, now());
    _markChanged();
  }

  void removeMedia(String mediaId) {
    mediaSelection.value = mediaSelection.value.remove(mediaId, now());
    _markChanged();
  }

  bool next() {
    errorMessage.value = null;
    if (step.value == MemoryAuthoringStep.media &&
        mediaSelection.value.activeMedia.isEmpty) {
      errorMessage.value = 'Add at least one photo or video to continue.';
      return false;
    }
    if (step.value.index >= MemoryAuthoringStep.values.length - 1) {
      return false;
    }
    step.value = MemoryAuthoringStep.values[step.value.index + 1];
    unawaited(saveDraft());
    return true;
  }

  bool back() {
    errorMessage.value = null;
    if (step.value.index == 0) return false;
    step.value = MemoryAuthoringStep.values[step.value.index - 1];
    unawaited(saveDraft());
    return true;
  }

  void setTitle(String value) {
    title.value = value;
    _markChanged();
  }

  void setCaption(String value) {
    caption.value = value;
    _markChanged();
  }

  void setMood(String value) {
    mood.value = value;
    _markChanged();
  }

  void setLocation(String value) {
    location.value = value;
    _markChanged();
  }

  void setOccasion(String value) {
    occasion.value = value;
    _markChanged();
  }

  void setTheme(String value) {
    themeKey.value = value;
    _markChanged();
  }

  void setTemplate(String value) {
    templateKey.value = value;
    _markChanged();
  }

  void setLayout(String value) {
    layoutKey.value = value;
    _markChanged();
  }

  void setMemoryDate(DateTime value) {
    memoryDate.value = _dateOnly(value);
    _markChanged();
  }

  Future<void> loadDraft() async {
    isLoadingDraft.value = true;
    errorMessage.value = null;
    try {
      final draft = await _draftRepository.load(
        accountId: accountId,
        draftId: draftId,
      );
      if (draft == null) return;
      _createdAt = draft.createdAt;
      step.value =
          MemoryAuthoringStep.values[draft.currentStep
              .clamp(0, MemoryAuthoringStep.values.length - 1)
              .toInt()];
      title.value = draft.title;
      caption.value = draft.caption;
      mood.value = draft.mood;
      location.value = draft.location;
      occasion.value = draft.occasion;
      memoryDate.value = draft.memoryDate;
      themeKey.value = draft.themeKey;
      templateKey.value = draft.templateKey;
      layoutKey.value = draft.layoutKey;
      mediaSelection.value = MemoryMediaSelection.fromMedia(
        draft.media,
        limits: mediaSelection.value.limits,
      );
      pendingSync.value = draft.pendingSync;
      hasUnsavedChanges.value = false;
    } on Object {
      errorMessage.value = 'We could not restore your local draft.';
    } finally {
      isLoadingDraft.value = false;
    }
  }

  Future<void> resumeDraft({
    required String draftId,
    required String memoryId,
  }) async {
    _autosaveTimer?.cancel();
    this.draftId = draftId;
    this.memoryId = memoryId;
    _resetDraftValues();
    await loadDraft();
  }

  void _resetDraftValues() {
    _createdAt = now();
    step.value = MemoryAuthoringStep.media;
    title.value = '';
    caption.value = '';
    mood.value = '';
    location.value = '';
    occasion.value = '';
    memoryDate.value = _dateOnly(now());
    themeKey.value = 'pawlum_default';
    templateKey.value = 'classic';
    layoutKey.value = 'single';
    mediaSelection.value = MemoryMediaSelection.empty(
      limits: mediaSelection.value.limits,
    );
    pendingSync.value = false;
    hasUnsavedChanges.value = false;
  }

  Future<void> saveDraft() async {
    _autosaveTimer?.cancel();
    _saveRequested = true;
    final existing = _saveInFlight;
    if (existing != null) {
      await existing;
      return;
    }
    final inFlight = _drainSaveRequests();
    _saveInFlight = inFlight;
    await inFlight;
    _saveInFlight = null;
  }

  Future<void> _drainSaveRequests() async {
    isSavingDraft.value = true;
    errorMessage.value = null;
    try {
      while (_saveRequested) {
        _saveRequested = false;
        final savedAt = now();
        final snapshot = MemoryAuthoringDraft(
          accountId: accountId,
          id: draftId,
          memoryId: memoryId,
          currentStep: step.value.index,
          title: title.value,
          caption: caption.value,
          mood: mood.value,
          location: location.value,
          occasion: occasion.value,
          memoryDate: memoryDate.value,
          themeKey: themeKey.value,
          templateKey: templateKey.value,
          layoutKey: layoutKey.value,
          media: mediaSelection.value.media,
          pendingSync: true,
          createdAt: _createdAt,
          updatedAt: savedAt,
        );
        await _draftRepository.save(snapshot);
      }
      pendingSync.value = true;
      hasUnsavedChanges.value = false;
    } on Object {
      errorMessage.value = 'We could not save your local draft.';
    } finally {
      isSavingDraft.value = false;
    }
  }

  Future<void> discardDraft() async {
    _autosaveTimer?.cancel();
    await _draftRepository.delete(accountId: accountId, draftId: draftId);
    hasUnsavedChanges.value = false;
    pendingSync.value = false;
    await onExit?.call();
  }

  Future<void> saveAndExit() async {
    await saveDraft();
    await onExit?.call();
  }

  Future<void> exitWithoutChanges() async => onExit?.call();

  void _markChanged() {
    hasUnsavedChanges.value = true;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(saveDraft()),
    );
  }

  String _validationMessage(List<MemoryValidationIssue> issues) {
    if (issues.contains(MemoryValidationIssue.tooManyImages)) {
      return 'You can add up to three photos.';
    }
    if (issues.contains(MemoryValidationIssue.tooManyVideos)) {
      return 'You can add one video.';
    }
    if (issues.contains(MemoryValidationIssue.unsupportedMediaType)) {
      return 'That file type is not supported.';
    }
    if (issues.contains(MemoryValidationIssue.mediaTooLarge)) {
      return 'That file is larger than the current upload limit.';
    }
    return 'That media could not be added.';
  }
}

class NoopMemoryMediaPicker implements MemoryMediaPicker {
  const NoopMemoryMediaPicker();

  @override
  Future<List<MemoryMediaCandidate>> pickImages({
    required int maxCount,
  }) async => const <MemoryMediaCandidate>[];

  @override
  Future<MemoryMediaCandidate?> pickVideo({
    required Duration maxDuration,
  }) async => null;
}

class _NoopMemoryAuthoringDraftRepository
    implements MemoryAuthoringDraftRepository {
  const _NoopMemoryAuthoringDraftRepository();

  @override
  Future<void> delete({
    required String accountId,
    required String draftId,
  }) async {}

  @override
  Future<MemoryAuthoringDraft?> load({
    required String accountId,
    required String draftId,
  }) async => null;

  @override
  Future<void> save(MemoryAuthoringDraft draft) async {}
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
