enum TimelineDraftIndicator { none, draft, editDraft }

class TimelineCursor {
  const TimelineCursor({required this.memoryDate, required this.memoryId});

  final DateTime memoryDate;
  final String memoryId;
}

class TimelineEntry {
  const TimelineEntry({
    required this.memoryId,
    required this.visibleVersionId,
    required this.petId,
    required this.title,
    required this.memoryDate,
    required this.draftIndicator,
    this.caption,
    this.coverObjectPath,
    this.workingVersionId,
  });

  final String memoryId;
  final String visibleVersionId;
  final String petId;
  final String title;
  final String? caption;
  final DateTime memoryDate;
  final String? coverObjectPath;
  final String? workingVersionId;
  final TimelineDraftIndicator draftIndicator;
}

class TimelinePage {
  TimelinePage({required List<TimelineEntry> entries, required this.nextCursor})
    : entries = List<TimelineEntry>.unmodifiable(entries);

  final List<TimelineEntry> entries;
  final TimelineCursor? nextCursor;
}

class TimelineMonthGroup {
  TimelineMonthGroup({
    required this.year,
    required this.month,
    required List<TimelineEntry> entries,
  }) : entries = List<TimelineEntry>.unmodifiable(entries);

  final int year;
  final int month;
  final List<TimelineEntry> entries;
}

List<TimelineMonthGroup> groupTimelineByMonth(List<TimelineEntry> entries) {
  final groups = <TimelineMonthGroup>[];
  for (final entry in entries) {
    if (groups.isEmpty ||
        groups.last.year != entry.memoryDate.year ||
        groups.last.month != entry.memoryDate.month) {
      groups.add(
        TimelineMonthGroup(
          year: entry.memoryDate.year,
          month: entry.memoryDate.month,
          entries: <TimelineEntry>[entry],
        ),
      );
      continue;
    }
    final current = groups.removeLast();
    groups.add(
      TimelineMonthGroup(
        year: current.year,
        month: current.month,
        entries: <TimelineEntry>[...current.entries, entry],
      ),
    );
  }
  return List<TimelineMonthGroup>.unmodifiable(groups);
}
