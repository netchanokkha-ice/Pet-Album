import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/core/theme/pawlum_theme.dart';
import 'package:pawlum/core/widgets/pawlum_widgets.dart';
import 'package:pawlum/features/account_access/data/repositories/in_memory_account_repository.dart';
import 'package:pawlum/features/account_access/domain/entities/account_identity.dart';
import 'package:pawlum/features/account_access/domain/entities/account_session.dart';
import 'package:pawlum/features/memory_authoring/data/in_memory_memory_lifecycle_repository.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_models.dart';
import 'package:pawlum/features/memory_authoring/presentation/controllers/memory_lifecycle_controller.dart';
import 'package:pawlum/features/timeline/presentation/controllers/memory_detail_controller.dart';
import 'package:pawlum/features/timeline/presentation/pages/memory_detail_view.dart';

void main() {
  tearDown(Get.reset);

  testWidgets(
    'detail renders the published version while an edit draft stays private',
    (WidgetTester tester) async {
      final aggregate = _publishedWithEditDraft();
      final lifecycleRepository = InMemoryMemoryLifecycleRepository()
        ..seed(aggregate);
      final accountRepository = _signedInAccount();
      final lifecycle = MemoryLifecycleController(
        lifecycleRepository,
        accountRepository,
        now: () => DateTime.utc(2026, 11, 1),
      );
      await lifecycle.load();
      var resumedVersionId = '';
      var exited = false;
      final detail = MemoryDetailController(
        lifecycle,
        onSafeExit: () async => exited = true,
        onResumeEdit: (MemoryAggregate memory) async {
          resumedVersionId = memory.currentWorkingVersion!.id;
        },
      );
      Get.put<MemoryDetailController>(detail);
      expect(detail.open(aggregate.id), isTrue);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: PawlumTheme.lightForWidth(390),
          home: const Scaffold(
            body: PawlumPaperBackground(child: MemoryDetailView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Published park day'), findsOneWidget);
      expect(find.text('Private edit title'), findsNothing);
      expect(find.text('A gentle afternoon under the trees.'), findsOneWidget);
      expect(find.text('Mood: Peaceful'), findsOneWidget);
      expect(find.text('Location: Chatuchak Park'), findsOneWidget);
      expect(find.text('Occasion: First picnic'), findsOneWidget);
      expect(find.text('Memory media unavailable'), findsOneWidget);
      expect(detail.publishedVersion?.id, 'published-version');

      await tester.tap(find.text('Resume editing'));
      await tester.pump();
      expect(resumedVersionId, 'working-version');

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -520));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Presentation · Warm Paper · Polaroid'),
        findsOneWidget,
      );

      detail.memoryDeleted(aggregate.id);
      await tester.pumpAndSettle();
      expect(find.text('Memory no longer available'), findsOneWidget);
      expect(find.text('Private edit title'), findsNothing);
      await tester.tap(find.text('Back to timeline'));
      await tester.pump();
      expect(exited, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}

InMemoryAccountRepository _signedInAccount() {
  final now = DateTime.utc(2026, 11, 1);
  return InMemoryAccountRepository(now: () => now)..seedSession(
    AccountSession(
      account: const AccountIdentity(
        id: 'fake-verified-account',
        email: 'memory@example.com',
        isEmailVerified: true,
        authMethods: <AccountAuthMethod>{AccountAuthMethod.emailPassword},
      ),
      startedAt: now.subtract(const Duration(minutes: 5)),
      expiresAt: now.add(const Duration(hours: 1)),
    ),
  );
}

MemoryAggregate _publishedWithEditDraft() {
  final createdAt = DateTime.utc(2026, 10, 30, 8);
  final publishedDraft = MemoryVersion.draft(
    id: 'published-version',
    memoryId: 'memory-detail',
    createdByAccountId: 'fake-verified-account',
    versionNumber: 1,
    title: 'Published park day',
    caption: 'A gentle afternoon under the trees.',
    mood: 'Peaceful',
    location: 'Chatuchak Park',
    occasion: 'First picnic',
    memoryDate: DateTime.utc(2026, 10, 28),
    today: createdAt,
    createdAt: createdAt,
    presentation: MemoryPresentation(
      themeKey: 'warm_paper',
      templateKey: 'polaroid',
      layoutKey: 'single',
    ),
    media: <MemoryMedia>[
      MemoryMedia.create(
            id: 'published-media',
            memoryVersionId: 'published-version',
            sourcePath: 'Z:\\private\\published.jpg',
            type: MemoryMediaType.image,
            sortOrder: 0,
            isCover: true,
            createdAt: createdAt,
          )
          .queue(createdAt.add(const Duration(seconds: 1)))
          .startUpload(createdAt.add(const Duration(seconds: 2)))
          .markUploaded(at: createdAt.add(const Duration(seconds: 3))),
    ],
  );
  final published =
      MemoryAggregate.draft(
            id: 'memory-detail',
            creatorAccountId: 'fake-verified-account',
            petIds: const <String>{'pet-1'},
            workingVersion: publishedDraft,
            createdAt: createdAt,
          )
          .beginPublishing(createdAt.add(const Duration(minutes: 1)))
          .publish(createdAt.add(const Duration(minutes: 2)));
  final working = MemoryVersion.draft(
    id: 'working-version',
    memoryId: 'memory-detail',
    createdByAccountId: 'fake-verified-account',
    versionNumber: 2,
    state: MemoryVersionState.editDraft,
    baseVersionId: 'published-version',
    title: 'Private edit title',
    caption: 'This working copy must never replace published reading.',
    memoryDate: DateTime.utc(2026, 10, 29),
    today: createdAt,
    createdAt: createdAt.add(const Duration(minutes: 3)),
  );
  return published.beginEditDraft(
    editDraft: working,
    at: createdAt.add(const Duration(minutes: 3)),
  );
}
