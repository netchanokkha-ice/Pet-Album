import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/timeline_models.dart';
import '../domain/repositories/timeline_repository.dart';

abstract interface class TimelineRpcClient {
  Future<Object?> call(String functionName, Map<String, Object?> parameters);
}

class SupabaseTimelineRpcClient implements TimelineRpcClient {
  const SupabaseTimelineRpcClient(this._client);

  final SupabaseClient _client;

  @override
  Future<Object?> call(String functionName, Map<String, Object?> parameters) =>
      _client.rpc(functionName, params: parameters);
}

class SupabaseTimelineRepository implements TimelineRepository {
  const SupabaseTimelineRepository(this._rpc);

  final TimelineRpcClient _rpc;

  @override
  Future<TimelinePage> loadPage({
    required String petId,
    TimelineCursor? after,
    int limit = 20,
  }) async {
    if (limit < 1 || limit > 50) {
      throw RangeError.range(limit, 1, 50, 'limit');
    }
    final response = await _rpc.call('get_memory_timeline', <String, Object?>{
      'p_pet_id': petId,
      'p_before_date': after == null ? null : _dateOnly(after.memoryDate),
      'p_before_memory_id': after?.memoryId,
      'p_limit': limit,
    });
    if (response is! List<Object?>) {
      throw const FormatException('Timeline RPC returned invalid data.');
    }
    final mapped = response.map(_mapRow).toList(growable: false);
    final hasMore = mapped.length > limit;
    final entries = hasMore ? mapped.take(limit).toList() : mapped;
    final last = entries.lastOrNull;
    return TimelinePage(
      entries: entries,
      nextCursor: hasMore && last != null
          ? TimelineCursor(memoryDate: last.memoryDate, memoryId: last.memoryId)
          : null,
    );
  }

  TimelineEntry _mapRow(Object? value) {
    if (value is! Map<Object?, Object?>) {
      throw const FormatException('Timeline row must be an object.');
    }
    final state = value['working_version_state'];
    return TimelineEntry(
      memoryId: _string(value, 'memory_id'),
      visibleVersionId: _string(value, 'visible_version_id'),
      petId: _string(value, 'pet_id'),
      title: _string(value, 'title'),
      caption: value['caption'] as String?,
      memoryDate: DateTime.parse(_string(value, 'memory_date')),
      coverObjectPath: value['cover_object_path'] as String?,
      workingVersionId: value['working_version_id'] as String?,
      draftIndicator: switch (state) {
        'draft' => TimelineDraftIndicator.draft,
        'edit_draft' => TimelineDraftIndicator.editDraft,
        _ => TimelineDraftIndicator.none,
      },
    );
  }

  String _string(Map<Object?, Object?> value, String key) {
    final field = value[key];
    if (field is! String || field.isEmpty) {
      throw FormatException('Timeline row omitted $key.');
    }
    return field;
  }

  String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
