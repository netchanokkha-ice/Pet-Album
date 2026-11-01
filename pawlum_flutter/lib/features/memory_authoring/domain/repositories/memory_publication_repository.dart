import '../entities/memory_publication.dart';

abstract interface class MemoryPublicationRepository {
  Future<MemoryPublicationResult> publish({
    required String memoryId,
    required String versionId,
  });

  Future<MemoryEditDraftReference> beginOrResumeEdit({
    required String memoryId,
    required String proposedVersionId,
  });

  Future<MemoryPublicationResult> publishChanges({
    required String memoryId,
    required String versionId,
  });
}
