import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/features/timeline/data/supabase_timeline_repository.dart';
import 'package:pawlum/features/timeline/domain/entities/timeline_models.dart';

void main() {
  test(
    'maps ordered page, draft indicators, cursor, and month groups',
    () async {
      final rpc = _FakeTimelineRpc(<Map<String, Object?>>[
        _row(
          memoryId: 'memory-3',
          date: '2026-11-01',
          workingState: 'edit_draft',
        ),
        _row(memoryId: 'memory-2', date: '2026-10-15', workingState: null),
        _row(memoryId: 'memory-1', date: '2026-10-01', workingState: 'draft'),
      ]);
      final repository = SupabaseTimelineRepository(rpc);

      final page = await repository.loadPage(petId: 'pet-1', limit: 2);

      expect(
        page.entries.map((TimelineEntry entry) => entry.memoryId),
        <String>['memory-3', 'memory-2'],
      );
      expect(
        page.entries.first.draftIndicator,
        TimelineDraftIndicator.editDraft,
      );
      expect(page.entries.first.workingVersionId, 'working-memory-3');
      expect(page.entries.last.draftIndicator, TimelineDraftIndicator.none);
      expect(page.nextCursor?.memoryId, 'memory-2');
      expect(rpc.lastParameters['p_pet_id'], 'pet-1');
      final groups = groupTimelineByMonth(page.entries);
      expect(groups, hasLength(2));
      expect((groups.first.year, groups.first.month), (2026, 11));
      expect((groups.last.year, groups.last.month), (2026, 10));
    },
  );

  test('passes a stable date/id cursor and returns the final page', () async {
    final rpc = _FakeTimelineRpc(<Map<String, Object?>>[
      _row(memoryId: 'memory-1', date: '2026-10-01', workingState: 'draft'),
    ]);
    final repository = SupabaseTimelineRepository(rpc);

    final page = await repository.loadPage(
      petId: 'pet-1',
      after: TimelineCursor(
        memoryDate: DateTime.utc(2026, 10, 15),
        memoryId: 'memory-2',
      ),
      limit: 2,
    );

    expect(rpc.lastParameters['p_before_date'], '2026-10-15');
    expect(rpc.lastParameters['p_before_memory_id'], 'memory-2');
    expect(page.entries.single.draftIndicator, TimelineDraftIndicator.draft);
    expect(page.nextCursor, isNull);
  });
}

Map<String, Object?> _row({
  required String memoryId,
  required String date,
  required String? workingState,
}) => <String, Object?>{
  'memory_id': memoryId,
  'visible_version_id': 'version-$memoryId',
  'pet_id': 'pet-1',
  'title': 'Title $memoryId',
  'caption': 'Caption $memoryId',
  'memory_date': date,
  'cover_object_path': 'account/memory/$memoryId.jpg',
  'working_version_id': workingState == null ? null : 'working-$memoryId',
  'working_version_state': workingState,
};

class _FakeTimelineRpc implements TimelineRpcClient {
  _FakeTimelineRpc(this.rows);

  final List<Map<String, Object?>> rows;
  Map<String, Object?> lastParameters = <String, Object?>{};

  @override
  Future<Object?> call(
    String functionName,
    Map<String, Object?> parameters,
  ) async {
    expect(functionName, 'get_memory_timeline');
    lastParameters = parameters;
    return rows;
  }
}
