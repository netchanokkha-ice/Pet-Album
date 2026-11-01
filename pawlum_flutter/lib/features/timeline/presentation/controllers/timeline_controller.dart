import 'dart:async';

import 'package:get/get.dart';

import '../../data/timeline_summary_cache.dart';
import '../../domain/entities/timeline_models.dart';
import '../../domain/repositories/timeline_repository.dart';

class TimelineController extends GetxController {
  TimelineController(
    this._repository, {
    required this.onAddMemory,
    required this.onOpenMemory,
    required this.onResumeDraft,
    this.pageSize = 20,
    TimelineSummaryCache? summaryCache,
  }) : summaryCache = summaryCache ?? TimelineSummaryCache();

  final TimelineRepository _repository;
  final Future<void> Function() onAddMemory;
  final Future<void> Function(TimelineEntry entry) onOpenMemory;
  final Future<void> Function(TimelineEntry entry) onResumeDraft;
  final int pageSize;
  final TimelineSummaryCache summaryCache;

  final petId = RxnString();
  final petName = 'Your pet'.obs;
  final petImagePath = RxnString();
  final entries = <TimelineEntry>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final pageErrorMessage = RxnString();
  final _removedEntries = <String, TimelineEntry>{};
  TimelineCursor? _nextCursor;

  List<TimelineMonthGroup> get groups => groupTimelineByMonth(entries);
  bool get hasMore => _nextCursor != null;

  Future<void> selectPet({
    required String id,
    required String name,
    String? imagePath,
  }) async {
    final changed = petId.value != id;
    petId.value = id;
    petName.value = name;
    petImagePath.value = imagePath;
    if (changed) {
      final cached = summaryCache.read(id);
      entries.assignAll(cached?.entries ?? const <TimelineEntry>[]);
      _nextCursor = cached?.nextCursor;
    }
    if (changed || entries.isEmpty) await loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    final selectedPetId = petId.value;
    if (selectedPetId == null || isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    pageErrorMessage.value = null;
    try {
      final page = await _repository.loadPage(
        petId: selectedPetId,
        limit: pageSize,
      );
      entries.assignAll(
        page.entries.where(
          (TimelineEntry entry) => !_removedEntries.containsKey(entry.memoryId),
        ),
      );
      _nextCursor = page.nextCursor;
      summaryCache.replace(selectedPetId, page);
    } on Object {
      errorMessage.value = 'We could not open this timeline. Try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNextPage() async {
    final selectedPetId = petId.value;
    final cursor = _nextCursor;
    if (selectedPetId == null || cursor == null || isLoadingMore.value) return;
    isLoadingMore.value = true;
    pageErrorMessage.value = null;
    try {
      final page = await _repository.loadPage(
        petId: selectedPetId,
        after: cursor,
        limit: pageSize,
      );
      final known = entries
          .map((TimelineEntry entry) => entry.memoryId)
          .toSet();
      entries.addAll(
        page.entries.where(
          (TimelineEntry entry) =>
              !known.contains(entry.memoryId) &&
              !_removedEntries.containsKey(entry.memoryId),
        ),
      );
      _nextCursor = page.nextCursor;
      summaryCache.append(selectedPetId, page);
    } on Object {
      pageErrorMessage.value = 'More memories could not be loaded. Try again.';
    } finally {
      isLoadingMore.value = false;
    }
  }

  void hideMemory(String memoryId) {
    final index = entries.indexWhere(
      (TimelineEntry entry) => entry.memoryId == memoryId,
    );
    if (index < 0) return;
    _removedEntries[memoryId] = entries[index];
    entries.removeAt(index);
    final selectedPetId = petId.value;
    if (selectedPetId != null) {
      summaryCache.removeEntry(selectedPetId, memoryId);
    }
  }

  void restoreMemory(String memoryId) {
    final restored = _removedEntries.remove(memoryId);
    if (restored == null || restored.petId != petId.value) return;
    entries.add(restored);
    entries.sort((TimelineEntry left, TimelineEntry right) {
      final date = right.memoryDate.compareTo(left.memoryDate);
      return date != 0 ? date : right.memoryId.compareTo(left.memoryId);
    });
    summaryCache.replace(
      restored.petId,
      TimelinePage(entries: entries, nextCursor: _nextCursor),
    );
  }

  Future<void> open(TimelineEntry entry) =>
      entry.draftIndicator == TimelineDraftIndicator.draft
      ? onResumeDraft(entry)
      : onOpenMemory(entry);

  Future<void> resume(TimelineEntry entry) => onResumeDraft(entry);

  Future<void> addMemory() => onAddMemory();

  void maybeLoadMore(double extentAfter) {
    if (extentAfter > 320 ||
        !hasMore ||
        isLoading.value ||
        isLoadingMore.value ||
        pageErrorMessage.value != null) {
      return;
    }
    unawaited(loadNextPage());
  }
}
