import '../domain/entities/memory_authoring_draft.dart';
import '../domain/repositories/memory_authoring_draft_repository.dart';

class InMemoryMemoryAuthoringDraftRepository
    implements MemoryAuthoringDraftRepository {
  final Map<String, MemoryAuthoringDraft> _drafts =
      <String, MemoryAuthoringDraft>{};

  String _key(String accountId, String draftId) => '$accountId::$draftId';

  @override
  Future<void> delete({
    required String accountId,
    required String draftId,
  }) async {
    _drafts.remove(_key(accountId, draftId));
  }

  @override
  Future<MemoryAuthoringDraft?> load({
    required String accountId,
    required String draftId,
  }) async {
    return _drafts[_key(accountId, draftId)];
  }

  @override
  Future<void> save(MemoryAuthoringDraft draft) async {
    _drafts[_key(draft.accountId, draft.id)] = draft;
  }
}
