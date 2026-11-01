class MemoryPublicationResult {
  const MemoryPublicationResult({
    required this.memoryId,
    required this.publishedVersionId,
    required this.replayed,
  });

  final String memoryId;
  final String publishedVersionId;
  final bool replayed;
}

class MemoryEditDraftReference {
  const MemoryEditDraftReference({
    required this.memoryId,
    required this.workingVersionId,
    required this.basePublishedVersionId,
    required this.resumed,
  });

  final String memoryId;
  final String workingVersionId;
  final String basePublishedVersionId;
  final bool resumed;
}
