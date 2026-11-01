import 'dart:collection';

import '../domain/entities/timeline_models.dart';

class CachedTimelineSummary {
  CachedTimelineSummary({
    required List<TimelineEntry> entries,
    required this.nextCursor,
  }) : entries = List<TimelineEntry>.unmodifiable(entries);

  final List<TimelineEntry> entries;
  final TimelineCursor? nextCursor;
}

class TimelineSummaryCache {
  TimelineSummaryCache({this.maxPets = 3, this.maxEntriesPerPet = 40}) {
    if (maxPets < 1) throw ArgumentError.value(maxPets, 'maxPets');
    if (maxEntriesPerPet < 1) {
      throw ArgumentError.value(maxEntriesPerPet, 'maxEntriesPerPet');
    }
  }

  final int maxPets;
  final int maxEntriesPerPet;
  final LinkedHashMap<String, CachedTimelineSummary> _values =
      LinkedHashMap<String, CachedTimelineSummary>();

  int get petCount => _values.length;
  int get entryCount => _values.values.fold<int>(
    0,
    (int count, CachedTimelineSummary value) => count + value.entries.length,
  );

  CachedTimelineSummary? read(String petId) {
    final value = _values.remove(petId);
    if (value == null) return null;
    _values[petId] = value;
    return value;
  }

  void replace(String petId, TimelinePage page) {
    _write(
      petId,
      CachedTimelineSummary(
        entries: page.entries.take(maxEntriesPerPet).toList(growable: false),
        nextCursor: page.nextCursor,
      ),
    );
  }

  void append(String petId, TimelinePage page) {
    final current = _values.remove(petId);
    final known = <String>{};
    final combined = <TimelineEntry>[];
    for (final entry in <TimelineEntry>[
      ...?current?.entries,
      ...page.entries,
    ]) {
      if (known.add(entry.memoryId)) combined.add(entry);
      if (combined.length == maxEntriesPerPet) break;
    }
    _write(
      petId,
      CachedTimelineSummary(entries: combined, nextCursor: page.nextCursor),
    );
  }

  void removeEntry(String petId, String memoryId) {
    final current = _values.remove(petId);
    if (current == null) return;
    _write(
      petId,
      CachedTimelineSummary(
        entries: current.entries
            .where((TimelineEntry entry) => entry.memoryId != memoryId)
            .toList(growable: false),
        nextCursor: current.nextCursor,
      ),
    );
  }

  void clear() => _values.clear();

  void _write(String petId, CachedTimelineSummary value) {
    _values.remove(petId);
    _values[petId] = value;
    while (_values.length > maxPets) {
      _values.remove(_values.keys.first);
    }
  }
}
