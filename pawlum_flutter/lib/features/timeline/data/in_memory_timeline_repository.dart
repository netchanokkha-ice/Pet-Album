import '../domain/entities/timeline_models.dart';
import '../domain/repositories/timeline_repository.dart';

class InMemoryTimelineRepository implements TimelineRepository {
  final Map<String, List<TimelineEntry>> _entries =
      <String, List<TimelineEntry>>{};

  void seed(TimelineEntry entry) {
    final values = _entries.putIfAbsent(entry.petId, () => <TimelineEntry>[]);
    values.removeWhere(
      (TimelineEntry value) => value.memoryId == entry.memoryId,
    );
    values.add(entry);
    values.sort(_newestFirst);
  }

  void seedAll(Iterable<TimelineEntry> entries) {
    for (final entry in entries) {
      seed(entry);
    }
  }

  @override
  Future<TimelinePage> loadPage({
    required String petId,
    TimelineCursor? after,
    int limit = 20,
  }) async {
    if (limit < 1 || limit > 50) {
      throw RangeError.range(limit, 1, 50, 'limit');
    }
    final values = List<TimelineEntry>.of(
      _entries[petId] ?? const <TimelineEntry>[],
    );
    final start = after == null
        ? 0
        : values.indexWhere(
                (TimelineEntry entry) =>
                    entry.memoryId == after.memoryId &&
                    entry.memoryDate == after.memoryDate,
              ) +
              1;
    final safeStart = start < 0 ? 0 : start;
    final end = (safeStart + limit).clamp(0, values.length);
    final page = values.sublist(safeStart.clamp(0, values.length), end);
    final hasMore = end < values.length;
    final last = page.lastOrNull;
    return TimelinePage(
      entries: page,
      nextCursor: hasMore && last != null
          ? TimelineCursor(memoryDate: last.memoryDate, memoryId: last.memoryId)
          : null,
    );
  }

  static int _newestFirst(TimelineEntry left, TimelineEntry right) {
    final date = right.memoryDate.compareTo(left.memoryDate);
    return date != 0 ? date : right.memoryId.compareTo(left.memoryId);
  }
}
