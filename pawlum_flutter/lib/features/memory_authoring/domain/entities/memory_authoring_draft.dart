import 'memory_models.dart';

class MemoryAuthoringDraft {
  MemoryAuthoringDraft({
    required this.accountId,
    required this.id,
    required this.memoryId,
    required this.currentStep,
    required this.memoryDate,
    required this.createdAt,
    required this.updatedAt,
    required List<MemoryMedia> media,
    this.title = '',
    this.caption = '',
    this.mood = '',
    this.location = '',
    this.occasion = '',
    this.themeKey = 'pawlum_default',
    this.templateKey = 'classic',
    this.layoutKey = 'single',
    this.pendingSync = true,
    this.draftKind = 'new_memory',
  }) : media = List<MemoryMedia>.unmodifiable(media);

  final String accountId;
  final String id;
  final String memoryId;
  final String draftKind;
  final int currentStep;
  final String title;
  final String caption;
  final String mood;
  final String location;
  final String occasion;
  final DateTime memoryDate;
  final String themeKey;
  final String templateKey;
  final String layoutKey;
  final List<MemoryMedia> media;
  final bool pendingSync;
  final DateTime createdAt;
  final DateTime updatedAt;
}
