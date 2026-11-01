import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/core/theme/pawlum_theme.dart';
import 'package:pawlum/core/widgets/pawlum_widgets.dart';
import 'package:pawlum/features/timeline/data/timeline_summary_cache.dart';
import 'package:pawlum/features/timeline/domain/entities/timeline_models.dart';
import 'package:pawlum/features/timeline/domain/repositories/timeline_repository.dart';
import 'package:pawlum/features/timeline/presentation/controllers/timeline_controller.dart';
import 'package:pawlum/features/timeline/presentation/pages/timeline_view.dart';

void main() {
  tearDown(Get.reset);

  test(
    'failed next page keeps summaries and succeeds with the same retry',
    () async {
      final first = TimelinePage(
        entries: <TimelineEntry>[_entry(1), _entry(2)],
        nextCursor: TimelineCursor(
          memoryDate: _entry(2).memoryDate,
          memoryId: _entry(2).memoryId,
        ),
      );
      final repository = _ScriptedTimelineRepository(<Object>[
        first,
        StateError('offline'),
        TimelinePage(entries: <TimelineEntry>[_entry(3)], nextCursor: null),
      ]);
      final controller = _controller(repository, pageSize: 2);

      await controller.selectPet(id: 'pet-1', name: 'Mochi');
      await controller.loadNextPage();

      expect(controller.entries.map((entry) => entry.memoryId), <String>[
        'memory-1',
        'memory-2',
      ]);
      expect(controller.pageErrorMessage.value, isNotNull);
      expect(controller.hasMore, isTrue);

      await controller.loadNextPage();

      expect(controller.entries.map((entry) => entry.memoryId), <String>[
        'memory-1',
        'memory-2',
        'memory-3',
      ]);
      expect(controller.pageErrorMessage.value, isNull);
      expect(controller.hasMore, isFalse);
      expect(repository.calls, 3);
    },
  );

  test('summary cache caps entries and evicts the least recently used pet', () {
    final cache = TimelineSummaryCache(maxPets: 2, maxEntriesPerPet: 2);
    cache.replace(
      'pet-1',
      TimelinePage(
        entries: <TimelineEntry>[_entry(1), _entry(2), _entry(3)],
        nextCursor: null,
      ),
    );
    cache.replace(
      'pet-2',
      TimelinePage(
        entries: <TimelineEntry>[_entry(4, petId: 'pet-2')],
        nextCursor: null,
      ),
    );
    expect(cache.read('pet-1')?.entries, hasLength(2));

    cache.replace(
      'pet-3',
      TimelinePage(
        entries: <TimelineEntry>[_entry(5, petId: 'pet-3')],
        nextCursor: null,
      ),
    );

    expect(cache.read('pet-2'), isNull);
    expect(cache.read('pet-1')?.entries, hasLength(2));
    expect(cache.read('pet-3')?.entries, hasLength(1));
    expect(cache.petCount, 2);
    expect(cache.entryCount, 3);
  });

  testWidgets('scrolling near the end lazy-loads with a visible skeleton', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final nextPage = Completer<TimelinePage>();
    final firstEntries = <TimelineEntry>[
      _entry(1),
      _entry(2),
      _entry(3),
      _entry(4),
    ];
    final repository = _CompletingTimelineRepository(
      first: TimelinePage(
        entries: firstEntries,
        nextCursor: TimelineCursor(
          memoryDate: firstEntries.last.memoryDate,
          memoryId: firstEntries.last.memoryId,
        ),
      ),
      next: nextPage,
    );
    final controller = _controller(repository, pageSize: 4);
    Get.put<TimelineController>(controller);
    await controller.selectPet(id: 'pet-1', name: 'Mochi');
    await tester.pumpWidget(
      GetMaterialApp(
        theme: PawlumTheme.lightForWidth(390),
        home: const Scaffold(
          body: PawlumPaperBackground(child: TimelineView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, -1800),
      1800,
    );
    await tester.pump();

    expect(controller.isLoadingMore.value, isTrue);
    expect(find.bySemanticsLabel('Loading more memories'), findsOneWidget);
    expect(
      controller.entries.map((TimelineEntry entry) => entry.memoryId),
      containsAll(<String>['memory-1', 'memory-2', 'memory-3', 'memory-4']),
    );

    nextPage.complete(
      TimelinePage(entries: <TimelineEntry>[_entry(5)], nextCursor: null),
    );
    await tester.pumpAndSettle();

    expect(controller.entries, hasLength(5));
    expect(controller.isLoadingMore.value, isFalse);
    expect(find.bySemanticsLabel('Loading more memories'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('page error stays retryable without clearing visible summaries', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final firstEntries = <TimelineEntry>[
      _entry(1),
      _entry(2),
      _entry(3),
      _entry(4),
    ];
    final repository = _ScriptedTimelineRepository(<Object>[
      TimelinePage(
        entries: firstEntries,
        nextCursor: TimelineCursor(
          memoryDate: firstEntries.last.memoryDate,
          memoryId: firstEntries.last.memoryId,
        ),
      ),
      StateError('offline'),
      TimelinePage(entries: <TimelineEntry>[_entry(5)], nextCursor: null),
    ]);
    final controller = _controller(repository, pageSize: 4);
    Get.put<TimelineController>(controller);
    await controller.selectPet(id: 'pet-1', name: 'Mochi');
    await tester.pumpWidget(
      GetMaterialApp(
        theme: PawlumTheme.lightForWidth(390),
        home: const Scaffold(
          body: PawlumPaperBackground(child: TimelineView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, -1800),
      1800,
    );
    await tester.pumpAndSettle();

    expect(controller.entries, hasLength(4));
    expect(
      find.text('More memories could not be loaded. Try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(repository.calls, 2);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(controller.entries, hasLength(5));
    expect(controller.entries.last.memoryId, 'memory-5');
    expect(controller.pageErrorMessage.value, isNull);
    expect(repository.calls, 3);
    expect(tester.takeException(), isNull);
  });
}

TimelineController _controller(
  TimelineRepository repository, {
  required int pageSize,
}) => TimelineController(
  repository,
  pageSize: pageSize,
  onAddMemory: () async {},
  onOpenMemory: (_) async {},
  onResumeDraft: (_) async {},
);

TimelineEntry _entry(int index, {String petId = 'pet-1'}) => TimelineEntry(
  memoryId: 'memory-$index',
  visibleVersionId: 'version-$index',
  petId: petId,
  title: 'Memory $index',
  caption: 'A cached summary for memory $index.',
  memoryDate: DateTime.utc(2026, 11, 2 - index),
  draftIndicator: TimelineDraftIndicator.none,
);

class _ScriptedTimelineRepository implements TimelineRepository {
  _ScriptedTimelineRepository(this.responses);

  final List<Object> responses;
  int calls = 0;

  @override
  Future<TimelinePage> loadPage({
    required String petId,
    TimelineCursor? after,
    int limit = 20,
  }) async {
    final response = responses[calls++];
    if (response is Error) throw response;
    return response as TimelinePage;
  }
}

class _CompletingTimelineRepository implements TimelineRepository {
  _CompletingTimelineRepository({required this.first, required this.next});

  final TimelinePage first;
  final Completer<TimelinePage> next;
  int calls = 0;

  @override
  Future<TimelinePage> loadPage({
    required String petId,
    TimelineCursor? after,
    int limit = 20,
  }) {
    calls += 1;
    return calls == 1 ? Future<TimelinePage>.value(first) : next.future;
  }
}
