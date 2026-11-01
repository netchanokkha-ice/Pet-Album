import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/features/app_shell/domain/entities/app_readiness.dart';
import 'package:pawlum/features/memory_authoring/data/in_memory_memory_lifecycle_repository.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_models.dart';
import 'package:pawlum/features/timeline/data/in_memory_timeline_repository.dart';
import 'package:pawlum/features/timeline/domain/entities/timeline_models.dart';
import 'package:pawlum/features/timeline/presentation/controllers/timeline_controller.dart';

import 'helpers/pump_pawlum_app.dart';

void main() {
  tearDown(Get.reset);

  test(
    'repository excludes deleted memory and restores its prior lifecycle/version',
    () async {
      final repository = InMemoryMemoryLifecycleRepository();
      final memory = _publishedMemory(isFirstMemory: false);
      repository.seed(memory);
      final deleted = await repository.softDelete(
        accountId: 'fake-verified-account',
        memoryId: memory.id,
        deletedAt: DateTime.utc(2026, 11, 1, 10),
      );

      expect(await repository.listActive('fake-verified-account'), isEmpty);
      expect(
        await repository.listRecoverable(
          accountId: 'fake-verified-account',
          at: DateTime.utc(2026, 11, 7),
        ),
        hasLength(1),
      );
      expect(deleted.preDeletionStatus, MemoryLifecycleStatus.published);

      final restored = await repository.restore(
        accountId: 'fake-verified-account',
        memoryId: memory.id,
        restoredAt: DateTime.utc(2026, 11, 7),
      );
      expect(restored.lifecycleStatus, MemoryLifecycleStatus.published);
      expect(restored.currentPublishedVersion?.id, 'version-1');
      expect(
        await repository.listActive('fake-verified-account'),
        hasLength(1),
      );
    },
  );

  testWidgets(
    'first memory warning supports Undo and Recently Deleted restore',
    (WidgetTester tester) async {
      final repository = InMemoryMemoryLifecycleRepository()
        ..seed(_publishedMemory(isFirstMemory: true));
      final timelineRepository = InMemoryTimelineRepository()
        ..seed(
          TimelineEntry(
            memoryId: 'memory-1',
            visibleVersionId: 'version-1',
            petId: 'pet-1',
            title: 'First sunny afternoon',
            caption: 'Mochi found the warmest patch of light.',
            memoryDate: DateTime.utc(2026, 10, 30),
            draftIndicator: TimelineDraftIndicator.none,
          ),
        );
      await tester.pumpPawlumApp(
        readiness: const AppReadiness(
          isAuthenticated: true,
          petCount: 1,
          pendingDraftCount: 0,
        ),
        memoryLifecycleRepository: repository,
        timelineRepository: timelineRepository,
      );

      await Get.find<TimelineController>().selectPet(
        id: 'pet-1',
        name: 'Mochi',
      );

      await tester.tap(find.text('Timeline').last);
      await tester.pumpAndSettle();
      expect(find.text('First sunny afternoon'), findsOneWidget);

      await tester.tap(find.byTooltip('Delete First sunny afternoon'));
      await tester.pumpAndSettle();
      expect(find.text('Delete first memory?'), findsOneWidget);
      expect(
        find.textContaining('will not delete the pet profile'),
        findsOneWidget,
      );
      await tester.tap(find.text('Move to Recently Deleted'));
      await tester.pumpAndSettle();
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('First sunny afternoon'), findsOneWidget);

      await tester.tap(find.byTooltip('Delete First sunny afternoon'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move to Recently Deleted'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Recently Deleted'));
      await tester.tap(find.text('Recently Deleted'));
      await tester.pumpAndSettle();
      expect(find.text('Memories'), findsOneWidget);
      expect(find.text('First sunny afternoon'), findsOneWidget);
      expect(find.text('7 days left'), findsOneWidget);

      await tester.tap(find.text('Restore memory'));
      await tester.pumpAndSettle();
      expect(find.text('Nothing to recover'), findsOneWidget);

      await tester.tap(find.text('Timeline').last);
      await tester.pumpAndSettle();
      expect(find.text('First sunny afternoon'), findsOneWidget);
    },
  );
}

MemoryAggregate _publishedMemory({required bool isFirstMemory}) {
  final now = DateTime.utc(2026, 10, 31, 8);
  final version = MemoryVersion.draft(
    id: 'version-1',
    memoryId: 'memory-1',
    createdByAccountId: 'fake-verified-account',
    versionNumber: 1,
    title: 'First sunny afternoon',
    caption: 'Mochi found the warmest patch of light.',
    memoryDate: DateTime.utc(2026, 10, 30),
    today: now,
    createdAt: now,
    media: <MemoryMedia>[
      MemoryMedia.create(
            id: 'media-1',
            memoryVersionId: 'version-1',
            sourcePath: '/private/version-1.jpg',
            type: MemoryMediaType.image,
            sortOrder: 0,
            isCover: true,
            createdAt: now,
          )
          .queue(now.add(const Duration(seconds: 1)))
          .startUpload(now.add(const Duration(seconds: 2)))
          .markUploaded(at: now.add(const Duration(seconds: 3))),
    ],
  );
  return MemoryAggregate.draft(
        id: 'memory-1',
        creatorAccountId: 'fake-verified-account',
        petIds: const <String>{'pet-1'},
        workingVersion: version,
        createdAt: now,
        isFirstMemory: isFirstMemory,
      )
      .beginPublishing(now.add(const Duration(minutes: 1)))
      .publish(now.add(const Duration(minutes: 2)));
}
