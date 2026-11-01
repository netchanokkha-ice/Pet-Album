import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/core/theme/pawlum_theme.dart';
import 'package:pawlum/features/memory_authoring/data/in_memory_memory_authoring_draft_repository.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_media_selection.dart';
import 'package:pawlum/features/memory_authoring/domain/entities/memory_models.dart';
import 'package:pawlum/features/memory_authoring/presentation/controllers/memory_authoring_controller.dart';
import 'package:pawlum/features/memory_authoring/presentation/pages/memory_authoring_page.dart';

void main() {
  tearDown(Get.reset);

  testWidgets(
    'four authoring steps retain values and use default presentation',
    (WidgetTester tester) async {
      final controller = MemoryAuthoringController(
        picker: _FixtureMediaPicker(),
        now: () => DateTime(2026, 11, 1, 10),
      );
      Get.put<MemoryAuthoringController>(controller);
      await _pumpAuthoring(tester);

      expect(
        find.bySemanticsLabel('Step 1 of 4, Choose media'),
        findsOneWidget,
      );
      await tester.tap(find.text('Add photos'));
      await tester.pumpAndSettle();
      expect(controller.mediaSelection.value.activeMedia, hasLength(1));
      expect(find.text('sunny-nap.jpg'), findsOneWidget);
      await tester.tap(find.text('Save draft'));
      await tester.pumpAndSettle();
      expect(find.text('Pending sync'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Step 2 of 4, Decorate'), findsOneWidget);
      expect(find.text('Pawlum default'), findsOneWidget);
      expect(find.text('Classic'), findsOneWidget);
      expect(find.text('Single'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Step 3 of 4, Tell the story'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const Key('memory-title-field')),
        'Sunny nap',
      );
      await tester.enterText(
        find.byKey(const Key('memory-caption-field')),
        'Mochi found the warmest corner.',
      );
      await tester.enterText(
        find.byKey(const Key('memory-mood-field')),
        'Cozy',
      );

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('sunny-nap.jpg'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Sunny nap'), findsOneWidget);
      expect(find.text('Mochi found the warmest corner.'), findsOneWidget);
      expect(controller.mood.value, 'Cozy');

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Step 4 of 4, Review memory'),
        findsOneWidget,
      );
      expect(find.text('Sunny nap'), findsOneWidget);
      expect(find.text('Mochi found the warmest corner.'), findsOneWidget);
      expect(
        find.text('Theme: Pawlum Default · Template: Classic · Layout: Single'),
        findsOneWidget,
      );
      expect(find.text('Finish review'), findsOneWidget);
    },
  );

  testWidgets('media step explains why an empty memory cannot continue', (
    WidgetTester tester,
  ) async {
    final controller = MemoryAuthoringController(
      picker: const NoopMemoryMediaPicker(),
      now: () => DateTime(2026, 11, 1),
    );
    Get.put<MemoryAuthoringController>(controller);
    await _pumpAuthoring(tester, size: const Size(1024, 768));

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(controller.errorMessage.value, isNotNull);
    expect(
      find.text('Add at least one photo or video to continue.'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Step 1 of 4, Choose media'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unsaved exit offers Save Draft, Discard, and Cancel choices', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryMemoryAuthoringDraftRepository();
    var exits = 0;
    final controller = MemoryAuthoringController(
      picker: const NoopMemoryMediaPicker(),
      draftRepository: repository,
      now: () => DateTime(2026, 11, 1),
      onExit: () async => exits++,
    );
    controller.step.value = MemoryAuthoringStep.story;
    Get.put<MemoryAuthoringController>(controller);
    await _pumpAuthoring(tester);

    await tester.enterText(
      find.byKey(const Key('memory-title-field')),
      'Unsaved title',
    );
    await tester.tap(find.byTooltip('Exit memory editor'));
    await tester.pump();

    expect(find.text('Save this memory draft?'), findsOneWidget);
    expect(find.text('Save draft'), findsWidgets);
    expect(find.text('Discard'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(exits, 1);
    expect(
      await repository.load(
        accountId: 'local-account',
        draftId: 'new-memory-draft',
      ),
      isNull,
    );
  });
}

Future<void> _pumpAuthoring(
  WidgetTester tester, {
  Size size = const Size(800, 700),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    GetMaterialApp(
      theme: PawlumTheme.lightForWidth(size.width),
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: MemoryAuthoringPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FixtureMediaPicker implements MemoryMediaPicker {
  @override
  Future<List<MemoryMediaCandidate>> pickImages({required int maxCount}) async {
    return const <MemoryMediaCandidate>[
      MemoryMediaCandidate(
        id: 'image-1',
        sourcePath: '/private/sunny-nap.jpg',
        type: MemoryMediaType.image,
        mimeType: 'image/jpeg',
        byteSize: 1024,
      ),
    ];
  }

  @override
  Future<MemoryMediaCandidate?> pickVideo({
    required Duration maxDuration,
  }) async => null;
}
