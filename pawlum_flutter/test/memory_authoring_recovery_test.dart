import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pawlum/core/database/pawlum_database.dart';
import 'package:pawlum/features/memory_authoring/data/drift_memory_authoring_draft_repository.dart';
import 'package:pawlum/features/memory_authoring/data/in_memory_memory_authoring_draft_repository.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_authoring_draft.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_media_selection.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_models.dart';
import 'package:pawlum/features/memory_authoring/presentation/controllers/memory_authoring_controller.dart';

void main() {
  test(
    'kill and relaunch restores the exact step, values, and local media',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'pawlum-memory-authoring-',
      );
      final file = File(path.join(directory.path, 'pawlum.sqlite'));
      final now = DateTime.utc(2026, 11, 1, 10);
      var database = PawlumDatabase.forTesting(NativeDatabase(file));
      var repository = DriftMemoryAuthoringDraftRepository(database);
      final first = MemoryAuthoringController(
        picker: const _RecoveryMediaPicker(),
        draftRepository: repository,
        accountId: 'account-a',
        draftId: 'draft-a',
        memoryId: 'memory-a',
        now: () => now,
      );

      await first.loadDraft();
      await first.addImages();
      expect(first.next(), isTrue);
      first.setTheme('sunny_day');
      expect(first.next(), isTrue);
      first.setTitle('Window sunshine');
      first.setCaption('Mochi slept here all afternoon.');
      first.setMood('Cozy');
      await first.saveDraft();
      first.onClose();
      await database.close();

      database = PawlumDatabase.forTesting(NativeDatabase(file));
      repository = DriftMemoryAuthoringDraftRepository(database);
      final relaunched = MemoryAuthoringController(
        picker: const NoopMemoryMediaPicker(),
        draftRepository: repository,
        accountId: 'account-a',
        draftId: 'draft-a',
        memoryId: 'memory-a',
        now: () => now.add(const Duration(minutes: 5)),
      );
      await relaunched.loadDraft();

      expect(relaunched.step.value, MemoryAuthoringStep.story);
      expect(relaunched.title.value, 'Window sunshine');
      expect(relaunched.caption.value, 'Mochi slept here all afternoon.');
      expect(relaunched.mood.value, 'Cozy');
      expect(relaunched.themeKey.value, 'sunny_day');
      expect(relaunched.mediaSelection.value.activeMedia.single.id, 'image-1');
      expect(
        relaunched.mediaSelection.value.activeMedia.single.sourcePath,
        '/private/window.jpg',
      );
      expect(relaunched.pendingSync.value, isTrue);
      expect(relaunched.hasUnsavedChanges.value, isFalse);
      expect(
        await repository.load(accountId: 'account-b', draftId: 'draft-a'),
        isNull,
      );

      await database.close();
      await directory.delete(recursive: true);
    },
  );

  test(
    'field changes autosave to local recovery and mark pending sync',
    () async {
      final repository = InMemoryMemoryAuthoringDraftRepository();
      final controller = MemoryAuthoringController(
        picker: const NoopMemoryMediaPicker(),
        draftRepository: repository,
        accountId: 'account-a',
        draftId: 'draft-a',
        now: () => DateTime.utc(2026, 11, 1, 10),
      );
      await controller.loadDraft();
      controller.setTitle('Autosaved title');

      await Future<void>.delayed(const Duration(milliseconds: 450));
      final stored = await repository.load(
        accountId: 'account-a',
        draftId: 'draft-a',
      );
      expect(stored?.title, 'Autosaved title');
      expect(stored?.pendingSync, isTrue);
      expect(controller.pendingSync.value, isTrue);
      expect(controller.hasUnsavedChanges.value, isFalse);
      controller.onClose();
    },
  );

  test(
    'resume routing switches draft identity and restores its exact step',
    () async {
      final now = DateTime.utc(2026, 11, 1, 10);
      final repository = InMemoryMemoryAuthoringDraftRepository();
      await repository.save(
        MemoryAuthoringDraft(
          accountId: 'account-a',
          id: 'working-version-2',
          memoryId: 'memory-2',
          currentStep: MemoryAuthoringStep.story.index,
          title: 'Private edit title',
          caption: 'Restored from the selected edit draft.',
          mood: 'Playful',
          location: 'Bangkok',
          memoryDate: DateTime.utc(2026, 10, 30),
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now,
          media: const <MemoryMedia>[],
          draftKind: 'edit_memory',
        ),
      );
      final controller = MemoryAuthoringController(
        picker: const NoopMemoryMediaPicker(),
        draftRepository: repository,
        accountId: 'account-a',
        draftId: 'unrelated-draft',
        memoryId: 'unrelated-memory',
        now: () => now,
      );
      controller.setTitle('Stale value');

      await controller.resumeDraft(
        draftId: 'working-version-2',
        memoryId: 'memory-2',
      );

      expect(controller.draftId, 'working-version-2');
      expect(controller.memoryId, 'memory-2');
      expect(controller.step.value, MemoryAuthoringStep.story);
      expect(controller.title.value, 'Private edit title');
      expect(
        controller.caption.value,
        'Restored from the selected edit draft.',
      );
      expect(controller.mood.value, 'Playful');
      expect(controller.location.value, 'Bangkok');
      expect(controller.hasUnsavedChanges.value, isFalse);
      controller.onClose();
    },
  );
}

class _RecoveryMediaPicker implements MemoryMediaPicker {
  const _RecoveryMediaPicker();

  @override
  Future<List<MemoryMediaCandidate>> pickImages({required int maxCount}) async {
    return const <MemoryMediaCandidate>[
      MemoryMediaCandidate(
        id: 'image-1',
        sourcePath: '/private/window.jpg',
        thumbnailPath: '/private/window-thumb.jpg',
        type: MemoryMediaType.image,
        mimeType: 'image/jpeg',
        byteSize: 2048,
      ),
    ];
  }

  @override
  Future<MemoryMediaCandidate?> pickVideo({
    required Duration maxDuration,
  }) async => null;
}
