import '../entities/memory_authoring_draft.dart';

abstract interface class MemoryAuthoringDraftRepository {
  Future<MemoryAuthoringDraft?> load({
    required String accountId,
    required String draftId,
  });

  Future<void> save(MemoryAuthoringDraft draft);

  Future<void> delete({required String accountId, required String draftId});
}
