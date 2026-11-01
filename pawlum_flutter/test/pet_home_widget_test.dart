import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawlum/features/app_shell/domain/entities/app_readiness.dart';
import 'package:pawlum/features/pet_profiles/data/repositories/in_memory_pet_profile_repository.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_models.dart';
import 'package:pawlum/features/pet_profiles/domain/repositories/pet_profile_repository.dart';
import 'package:pawlum/features/pet_profiles/presentation/controllers/pet_home_controller.dart';

import 'helpers/pump_pawlum_app.dart';

void main() {
  tearDown(Get.reset);

  const ready = AppReadiness(
    isAuthenticated: true,
    petCount: 2,
    pendingDraftCount: 0,
  );

  testWidgets('multiple pet cards stay account-scoped and select a timeline', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryPetProfileRepository();
    await _seedPet(
      repository,
      'fake-verified-account',
      'pet-a',
      'Mochi',
      PetType.cat,
    );
    await _seedPet(
      repository,
      'fake-verified-account',
      'pet-b',
      'Pudding',
      PetType.dog,
    );
    await _seedPet(
      repository,
      'other-account',
      'pet-c',
      'Luna',
      PetType.rabbit,
    );

    await tester.pumpPawlumApp(
      readiness: ready,
      petProfileRepository: repository,
    );

    expect(find.text('Mochi'), findsOneWidget);
    expect(find.text('Pudding'), findsOneWidget);
    expect(find.text('Luna'), findsNothing);

    await tester.tap(find.text('Pudding'));
    await tester.pumpAndSettle();
    expect(Get.find<PetHomeController>().selectedPetId.value, 'pet-b');
    expect(find.text('Timeline'), findsWidgets);
  });

  testWidgets('add-pet entry opens the onboarding flow', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryPetProfileRepository();
    await _seedPet(
      repository,
      'fake-verified-account',
      'pet-a',
      'Mochi',
      PetType.cat,
    );
    await tester.pumpPawlumApp(
      readiness: ready,
      petProfileRepository: repository,
    );

    await tester.tap(find.text('Add pet'));
    await tester.pumpAndSettle();
    expect(find.text('Let’s meet your pet'), findsOneWidget);
  });

  testWidgets('owner edits name and photo while type stays read-only', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryPetProfileRepository();
    await _seedPet(
      repository,
      'fake-verified-account',
      'pet-a',
      'Mochi',
      PetType.cat,
    );
    await tester.pumpPawlumApp(
      readiness: ready,
      petProfileRepository: repository,
      petProfilePhotoPicker: const _FixturePhotoPicker('/private/mochi.jpg'),
    );

    await tester.tap(find.byTooltip('Edit Mochi'));
    await tester.pumpAndSettle();
    expect(find.text('Pet type · read only'), findsOneWidget);
    expect(find.text('Cat'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('edit-pet-name-field')),
      'Mochi Bean',
    );
    await tester.tap(find.text('Choose profile photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Mochi Bean'), findsOneWidget);
    final updated = (await repository.listActivePets(
      'fake-verified-account',
    )).single;
    expect(updated.type, PetType.cat);
    expect(updated.profileImagePath, '/private/mochi.jpg');
  });

  testWidgets('empty repository offers an add-pet action', (
    WidgetTester tester,
  ) async {
    await tester.pumpPawlumApp(
      readiness: ready,
      petProfileRepository: InMemoryPetProfileRepository(),
    );

    expect(find.text('No pet journals yet'), findsOneWidget);
    expect(find.text('Add your first pet'), findsOneWidget);
  });

  testWidgets('loading and error states are explicit and retryable', (
    WidgetTester tester,
  ) async {
    final delayed = _DelayedPetProfileRepository();
    await tester.pumpPawlumApp(
      readiness: ready,
      petProfileRepository: delayed,
      settle: false,
    );
    await tester.pump();
    await tester.pump();
    expect(find.bySemanticsLabel('Loading pet journals'), findsOneWidget);
    delayed.complete(<PetProfile>[]);
    await tester.pumpAndSettle();
    expect(find.text('No pet journals yet'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    Get.reset();
    await tester.pumpPawlumApp(
      readiness: ready,
      petProfileRepository: _FailingPetProfileRepository(),
    );
    expect(find.text('Pet journals unavailable'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}

Future<void> _seedPet(
  InMemoryPetProfileRepository repository,
  String accountId,
  String petId,
  String name,
  PetType type,
) async {
  await repository.initializePetJournal(
    InitializePetJournalCommand(
      accountId: accountId,
      petId: petId,
      firstMemoryId: 'memory-$petId',
      input: PetOnboardingInput(name: name, type: type),
      createdAt: DateTime.utc(2026, 11, 1),
    ),
  );
}

class _FixturePhotoPicker implements PetProfilePhotoPicker {
  const _FixturePhotoPicker(this.path);

  final String path;

  @override
  Future<String?> pickPhoto() async => path;
}

class _DelayedPetProfileRepository implements PetProfileRepository {
  final Completer<List<PetProfile>> _completer = Completer<List<PetProfile>>();

  void complete(List<PetProfile> pets) => _completer.complete(pets);

  @override
  Future<List<PetProfile>> listActivePets(String accountId) =>
      _completer.future;

  @override
  Future<List<PetProfile>> listRecoverableDeletedPets({
    required String accountId,
    required DateTime at,
  }) => throw UnimplementedError();

  @override
  Future<InitializedPetJournal> initializePetJournal(
    InitializePetJournalCommand command,
  ) => throw UnimplementedError();

  @override
  Future<PetProfile> updateProfile({
    required String accountId,
    required String petId,
    required String name,
    required DateTime updatedAt,
    String? profileImagePath,
    PetType? requestedType,
  }) => throw UnimplementedError();

  @override
  Future<PetProfile> softDeletePet({
    required String accountId,
    required String petId,
    required DateTime deletedAt,
  }) => throw UnimplementedError();

  @override
  Future<PetProfile> restorePet({
    required String accountId,
    required String petId,
    required DateTime restoredAt,
  }) => throw UnimplementedError();
}

class _FailingPetProfileRepository implements PetProfileRepository {
  @override
  Future<List<PetProfile>> listActivePets(String accountId) async {
    throw StateError('offline');
  }

  @override
  Future<List<PetProfile>> listRecoverableDeletedPets({
    required String accountId,
    required DateTime at,
  }) async {
    throw StateError('offline');
  }

  @override
  Future<InitializedPetJournal> initializePetJournal(
    InitializePetJournalCommand command,
  ) => throw UnimplementedError();

  @override
  Future<PetProfile> updateProfile({
    required String accountId,
    required String petId,
    required String name,
    required DateTime updatedAt,
    String? profileImagePath,
    PetType? requestedType,
  }) => throw UnimplementedError();

  @override
  Future<PetProfile> softDeletePet({
    required String accountId,
    required String petId,
    required DateTime deletedAt,
  }) => throw UnimplementedError();

  @override
  Future<PetProfile> restorePet({
    required String accountId,
    required String petId,
    required DateTime restoredAt,
  }) => throw UnimplementedError();
}
