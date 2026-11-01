import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/features/app_shell/domain/entities/app_readiness.dart';
import 'package:pawlum/features/pet_profiles/data/repositories/in_memory_pet_profile_repository.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_models.dart';
import 'package:pawlum/features/pet_profiles/domain/repositories/pet_profile_repository.dart';

import 'helpers/pump_pawlum_app.dart';

void main() {
  tearDown(Get.reset);

  testWidgets(
    'deleted pet leaves Home, shows countdown, restores to its journal',
    (WidgetTester tester) async {
      final repository = InMemoryPetProfileRepository();
      await _seedPet(repository, 'pet-mochi', 'Mochi', PetType.cat);
      await _seedPet(repository, 'pet-pudding', 'Pudding', PetType.dog);

      await tester.pumpPawlumApp(
        readiness: const AppReadiness(
          isAuthenticated: true,
          petCount: 2,
          pendingDraftCount: 0,
        ),
        petProfileRepository: repository,
      );

      expect(find.bySemanticsLabel('Mochi pet journal'), findsOneWidget);
      expect(find.bySemanticsLabel('Pudding pet journal'), findsOneWidget);

      await tester.tap(find.byTooltip('Edit Mochi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move to Recently Deleted'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Mochi?'), findsOneWidget);
      await tester.tap(find.text('Delete pet'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Mochi pet journal'), findsNothing);
      expect(find.bySemanticsLabel('Pudding pet journal'), findsOneWidget);

      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Recently Deleted'));
      await tester.tap(find.text('Recently Deleted'));
      await tester.pumpAndSettle();

      expect(find.text('Mochi'), findsOneWidget);
      expect(find.text('7 days left'), findsOneWidget);
      expect(find.text('Restore'), findsOneWidget);

      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();
      expect(find.text('Nothing to recover'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Mochi pet journal'), findsOneWidget);
      expect(find.bySemanticsLabel('Pudding pet journal'), findsOneWidget);
    },
  );
}

Future<void> _seedPet(
  InMemoryPetProfileRepository repository,
  String petId,
  String name,
  PetType type,
) {
  return repository.initializePetJournal(
    InitializePetJournalCommand(
      accountId: 'fake-verified-account',
      petId: petId,
      firstMemoryId: 'memory-$petId',
      input: PetOnboardingInput(name: name, type: type),
      createdAt: DateTime.now(),
    ),
  );
}
