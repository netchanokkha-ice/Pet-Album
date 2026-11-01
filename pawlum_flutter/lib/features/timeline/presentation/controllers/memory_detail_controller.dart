import 'package:get/get.dart';

import '../../../memory_authoring/domain/entities/memory_models.dart';
import '../../../memory_authoring/presentation/controllers/memory_lifecycle_controller.dart';

class MemoryDetailController extends GetxController {
  MemoryDetailController(
    this._lifecycleController, {
    required this.onSafeExit,
    required this.onResumeEdit,
  });

  final MemoryLifecycleController _lifecycleController;
  final Future<void> Function() onSafeExit;
  final Future<void> Function(MemoryAggregate memory) onResumeEdit;

  final memory = Rxn<MemoryAggregate>();
  final unavailable = false.obs;

  MemoryVersion? get publishedVersion => memory.value?.currentPublishedVersion;

  bool open(String memoryId) {
    final aggregate = _lifecycleController.activeMemory(memoryId);
    final published = aggregate?.currentPublishedVersion;
    if (aggregate == null || published == null) {
      memory.value = null;
      unavailable.value = true;
      return false;
    }
    memory.value = aggregate;
    unavailable.value = false;
    return true;
  }

  void memoryDeleted(String memoryId) {
    if (memory.value?.id != memoryId) return;
    memory.value = null;
    unavailable.value = true;
  }

  Future<void> resumeEdit() async {
    final aggregate = memory.value;
    if (aggregate?.currentWorkingVersion == null) return;
    await onResumeEdit(aggregate!);
  }

  Future<void> exit() => onSafeExit();
}
