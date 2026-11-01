import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/features/memory_authoring/data/supabase_memory_publication_repository.dart';

void main() {
  test('initial publication is idempotent through the repository', () async {
    final remote = _FakeAtomicMemoryRpc.initialDraft();
    final repository = SupabaseMemoryPublicationRepository(remote);

    final first = await repository.publish(
      memoryId: 'memory-1',
      versionId: 'version-1',
    );
    final retry = await repository.publish(
      memoryId: 'memory-1',
      versionId: 'version-1',
    );

    expect(first.replayed, isFalse);
    expect(first.publishedVersionId, 'version-1');
    expect(retry.replayed, isTrue);
    expect(remote.publishTransitions, 1);
  });

  test(
    'edit draft resumes and old published version stays readable until promotion',
    () async {
      final remote = _FakeAtomicMemoryRpc.published();
      final repository = SupabaseMemoryPublicationRepository(remote);

      final edit = await repository.beginOrResumeEdit(
        memoryId: 'memory-1',
        proposedVersionId: 'version-2',
      );
      remote.titles[edit.workingVersionId] = 'Edited private title';

      expect(edit.resumed, isFalse);
      expect(edit.basePublishedVersionId, 'version-1');
      expect(remote.readPublishedTitle(), 'Original public title');
      expect(remote.currentPublishedVersionId, 'version-1');

      final resumed = await repository.beginOrResumeEdit(
        memoryId: 'memory-1',
        proposedVersionId: 'unused-version-3',
      );
      expect(resumed.resumed, isTrue);
      expect(resumed.workingVersionId, 'version-2');
      expect(remote.readPublishedTitle(), 'Original public title');

      final promoted = await repository.publishChanges(
        memoryId: 'memory-1',
        versionId: resumed.workingVersionId,
      );
      expect(promoted.replayed, isFalse);
      expect(remote.readPublishedTitle(), 'Edited private title');
      expect(remote.currentWorkingVersionId, isNull);

      final retry = await repository.publishChanges(
        memoryId: 'memory-1',
        versionId: resumed.workingVersionId,
      );
      expect(retry.replayed, isTrue);
      expect(remote.promotionTransitions, 1);
    },
  );
}

class _FakeAtomicMemoryRpc implements MemoryPublicationRpcClient {
  _FakeAtomicMemoryRpc._({
    required this.lifecycle,
    required this.currentPublishedVersionId,
    required this.currentWorkingVersionId,
    required this.titles,
  });

  factory _FakeAtomicMemoryRpc.initialDraft() => _FakeAtomicMemoryRpc._(
    lifecycle: 'draft',
    currentPublishedVersionId: null,
    currentWorkingVersionId: 'version-1',
    titles: <String, String>{'version-1': 'First title'},
  );

  factory _FakeAtomicMemoryRpc.published() => _FakeAtomicMemoryRpc._(
    lifecycle: 'published',
    currentPublishedVersionId: 'version-1',
    currentWorkingVersionId: null,
    titles: <String, String>{'version-1': 'Original public title'},
  );

  String lifecycle;
  String? currentPublishedVersionId;
  String? currentWorkingVersionId;
  final Map<String, String> titles;
  int publishTransitions = 0;
  int promotionTransitions = 0;

  String readPublishedTitle() => titles[currentPublishedVersionId]!;

  @override
  Future<Object?> call(
    String functionName,
    Map<String, Object?> parameters,
  ) async {
    final memoryId = parameters['p_memory_id']! as String;
    final versionId = parameters['p_version_id']! as String;
    return switch (functionName) {
      'publish_memory' => _publish(memoryId, versionId),
      'begin_memory_edit' => _beginEdit(memoryId, versionId),
      'promote_memory_version' => _promote(memoryId, versionId),
      _ => throw StateError('Unexpected RPC: $functionName'),
    };
  }

  Map<String, Object?> _publish(String memoryId, String versionId) {
    final replayed =
        lifecycle == 'published' && currentPublishedVersionId == versionId;
    if (!replayed) {
      if (lifecycle != 'draft' || currentWorkingVersionId != versionId) {
        throw StateError('memory is not ready for publication');
      }
      lifecycle = 'published';
      currentPublishedVersionId = versionId;
      currentWorkingVersionId = null;
      publishTransitions += 1;
    }
    return <String, Object?>{
      'memory_id': memoryId,
      'published_version_id': versionId,
      'replayed': replayed,
    };
  }

  Map<String, Object?> _beginEdit(String memoryId, String versionId) {
    final existing = currentWorkingVersionId;
    if (existing != null) {
      return <String, Object?>{
        'memory_id': memoryId,
        'working_version_id': existing,
        'base_published_version_id': currentPublishedVersionId!,
        'replayed': true,
      };
    }
    if (lifecycle != 'published' || currentPublishedVersionId == null) {
      throw StateError('memory is not published');
    }
    titles[versionId] = titles[currentPublishedVersionId]!;
    currentWorkingVersionId = versionId;
    return <String, Object?>{
      'memory_id': memoryId,
      'working_version_id': versionId,
      'base_published_version_id': currentPublishedVersionId!,
      'replayed': false,
    };
  }

  Map<String, Object?> _promote(String memoryId, String versionId) {
    final replayed =
        currentPublishedVersionId == versionId &&
        currentWorkingVersionId == null;
    if (!replayed) {
      if (lifecycle != 'published' || currentWorkingVersionId != versionId) {
        throw StateError('memory is not ready for promotion');
      }
      currentPublishedVersionId = versionId;
      currentWorkingVersionId = null;
      promotionTransitions += 1;
    }
    return <String, Object?>{
      'memory_id': memoryId,
      'published_version_id': versionId,
      'replayed': replayed,
    };
  }
}
