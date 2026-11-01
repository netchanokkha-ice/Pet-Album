import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/core/theme/pawlum_theme.dart';
import 'package:pawlum/core/widgets/pawlum_widgets.dart';
import 'package:pawlum/features/timeline/data/in_memory_timeline_repository.dart';
import 'package:pawlum/features/timeline/domain/entities/timeline_models.dart';
import 'package:pawlum/features/timeline/presentation/controllers/timeline_controller.dart';
import 'package:pawlum/features/timeline/presentation/pages/timeline_view.dart';

void main() {
  setUpAll(_loadGoldenFonts);
  tearDown(Get.reset);

  testWidgets(
    'portrait scrapbook groups mixed years and labels every draft state',
    (WidgetTester tester) async {
      final repository = InMemoryTimelineRepository()..seedAll(_mixedTimeline);
      await _pumpTimeline(tester, repository: repository);

      expect(find.text('Mochi'), findsOneWidget);
      expect(find.text('October 2026'), findsOneWidget);
      expect(find.text('Draft — tap to continue'), findsOneWidget);
      expect(find.text('Unpublished edits'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.text('December 2025'),
        360,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('December 2025'), findsOneWidget);
      expect(find.text('วันที่ฝนตกพรำ ๆ แต่ในบ้านอบอุ่นเสมอ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('portrait scrapbook has a useful empty state', (
    WidgetTester tester,
  ) async {
    await _pumpTimeline(tester, repository: InMemoryTimelineRepository());

    expect(find.text('No memories here yet'), findsOneWidget);
    expect(find.text('Add a memory'), findsOneWidget);
    expect(find.textContaining('Mochi’s scrapbook'), findsOneWidget);
  });

  testWidgets('broken cover media keeps the memory readable', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryTimelineRepository()
      ..seed(
        TimelineEntry(
          memoryId: 'broken-media',
          visibleVersionId: 'broken-version',
          petId: 'pet-1',
          title: 'The photo is still processing',
          caption: 'The story remains available even when its cover does not.',
          memoryDate: DateTime.utc(2026, 9, 12),
          coverObjectPath: 'Z:\\missing\\memory.jpg',
          draftIndicator: TimelineDraftIndicator.none,
        ),
      );
    await _pumpTimeline(tester, repository: repository);
    await tester.pumpAndSettle();

    expect(find.text('The photo is still processing'), findsOneWidget);
    expect(find.text('Memory photo unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'published cards open detail while drafts resume working versions',
    (WidgetTester tester) async {
      final opened = <String>[];
      final resumed = <String>[];
      final repository = InMemoryTimelineRepository()
        ..seedAll(<TimelineEntry>[
          TimelineEntry(
            memoryId: 'draft-route',
            visibleVersionId: 'draft-working',
            workingVersionId: 'draft-working',
            petId: 'pet-1',
            title: 'Draft route',
            memoryDate: DateTime.utc(2026, 11, 1),
            draftIndicator: TimelineDraftIndicator.draft,
          ),
          TimelineEntry(
            memoryId: 'edit-route',
            visibleVersionId: 'published-visible',
            workingVersionId: 'edit-working',
            petId: 'pet-1',
            title: 'Published route',
            memoryDate: DateTime.utc(2026, 10, 31),
            draftIndicator: TimelineDraftIndicator.editDraft,
          ),
        ]);
      await _pumpTimeline(
        tester,
        repository: repository,
        onOpenMemory: (entry) async => opened.add(entry.visibleVersionId),
        onResumeDraft: (entry) async => resumed.add(entry.workingVersionId!),
      );

      await tester.tap(find.text('Draft route'));
      await tester.pump();
      expect(resumed, <String>['draft-working']);
      expect(opened, isEmpty);

      await tester.tap(find.text('Published route'));
      await tester.pump();
      expect(opened, <String>['published-visible']);
      await tester.scrollUntilVisible(
        find.text('Resume edits'),
        360,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -120));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resume edits'));
      await tester.pump();
      expect(resumed, <String>['draft-working', 'edit-working']);
    },
  );

  testWidgets('rotation keeps the active pet and exposes every memory', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryTimelineRepository()..seedAll(_mixedTimeline);
    await _pumpTimeline(tester, repository: repository);

    expect(find.byKey(const Key('timeline-portrait-layout')), findsOneWidget);
    expect(Get.find<TimelineController>().petId.value, 'pet-1');
    expect(find.text('Mochi'), findsOneWidget);

    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('timeline-landscape-layout')), findsOneWidget);
    expect(Get.find<TimelineController>().petId.value, 'pet-1');
    expect(find.text('Mochi'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    await expectLater(
      find.byKey(const Key('timeline-test-surface')),
      matchesGoldenFile('goldens/timeline_landscape_phone.png'),
    );
    await tester.scrollUntilVisible(
      find.text('Our first holiday together'),
      420,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Our first holiday together'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('timeline-portrait-layout')), findsOneWidget);
    expect(Get.find<TimelineController>().petName.value, 'Mochi');
    expect(tester.takeException(), isNull);
  });

  testWidgets('portrait scrapbook matches its phone golden', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = InMemoryTimelineRepository()
      ..seedAll(_mixedTimeline.take(2));
    await _pumpTimeline(tester, repository: repository);

    await expectLater(
      find.byKey(const Key('timeline-test-surface')),
      matchesGoldenFile('goldens/timeline_portrait_phone.png'),
    );
  });
}

Future<void> _pumpTimeline(
  WidgetTester tester, {
  required InMemoryTimelineRepository repository,
  Future<void> Function(TimelineEntry entry)? onOpenMemory,
  Future<void> Function(TimelineEntry entry)? onResumeDraft,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final controller = TimelineController(
    repository,
    onAddMemory: () async {},
    onOpenMemory: onOpenMemory ?? (_) async {},
    onResumeDraft: onResumeDraft ?? (_) async {},
  );
  Get.put<TimelineController>(controller);
  await controller.selectPet(id: 'pet-1', name: 'Mochi');
  await tester.pumpWidget(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: PawlumTheme.lightForWidth(390),
      home: Scaffold(
        body: PawlumPaperBackground(
          child: KeyedSubtree(
            key: const Key('timeline-test-surface'),
            child: const TimelineView(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<TimelineEntry> get _mixedTimeline => <TimelineEntry>[
  TimelineEntry(
    memoryId: 'draft-memory',
    visibleVersionId: 'draft-version',
    petId: 'pet-1',
    title: 'วันนี้โมจิแอบปีนขึ้นไปนอนบนชั้นหนังสืออีกแล้ว',
    caption:
        'วันที่ฝนตกพรำ ๆ เราอยู่บ้านด้วยกันทั้งวัน — a very long bilingual memory that should wrap gently without pushing any action off the paper.',
    memoryDate: DateTime.utc(2026, 10, 31),
    draftIndicator: TimelineDraftIndicator.draft,
  ),
  TimelineEntry(
    memoryId: 'published-memory',
    visibleVersionId: 'published-version',
    petId: 'pet-1',
    title: 'A sunny afternoon by the window',
    caption: 'Warm paws, a quiet room, and the smallest happy purr.',
    memoryDate: DateTime.utc(2026, 10, 2),
    draftIndicator: TimelineDraftIndicator.editDraft,
  ),
  TimelineEntry(
    memoryId: 'older-memory',
    visibleVersionId: 'older-version',
    petId: 'pet-1',
    title: 'Our first holiday together',
    caption: 'วันที่ฝนตกพรำ ๆ แต่ในบ้านอบอุ่นเสมอ',
    memoryDate: DateTime.utc(2025, 12, 24),
    draftIndicator: TimelineDraftIndicator.none,
  ),
];

Future<void> _loadGoldenFonts() async {
  final fonts = <(String, String)>[
    ('PawlumJua', 'assets/fonts/Jua-Regular.ttf'),
    ('PawlumItim', 'assets/fonts/Itim-Regular.ttf'),
    ('PawlumCaveat', 'assets/fonts/Caveat-Variable.ttf'),
    ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
  ];
  for (final (family, assetPath) in fonts) {
    final loader = FontLoader(family)..addFont(rootBundle.load(assetPath));
    await loader.load();
  }
}
