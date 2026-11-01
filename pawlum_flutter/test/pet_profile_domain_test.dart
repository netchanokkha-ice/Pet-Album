import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/features/pet_profiles/data/repositories/in_memory_pet_profile_repository.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_models.dart';
import 'package:pawlum/features/pet_profiles/domain/repositories/pet_profile_repository.dart';
import 'package:pawlum/features/pet_profiles/domain/use_cases/pet_profile_use_cases.dart';

void main() {
  late DateTime today;
  late InMemoryPetProfileRepository repository;
  late CreatePetJournal createPet;

  setUp(() {
    today = DateTime.utc(2026, 11, 1, 10);
    repository = InMemoryPetProfileRepository();
    createPet = CreatePetJournal(repository, today: () => today);
  });

  test('requires a pet name and supported type', () async {
    final command = _command(
      accountId: 'account-a',
      petId: 'pet-a',
      input: const PetOnboardingInput(name: '  ', type: null),
      createdAt: today,
    );

    await expectLater(
      createPet(command),
      throwsA(
        isA<PetOnboardingValidationFailure>().having(
          (PetOnboardingValidationFailure failure) => failure.issues,
          'issues',
          containsAll(<PetOnboardingIssue>[
            PetOnboardingIssue.nameRequired,
            PetOnboardingIssue.typeRequired,
          ]),
        ),
      ),
    );
    expect(await repository.listActivePets('account-a'), isEmpty);
  });

  test('Other type requires and preserves a custom label', () async {
    await expectLater(
      createPet(
        _command(
          accountId: 'account-a',
          petId: 'pet-a',
          input: const PetOnboardingInput(name: 'Mochi', type: PetType.other),
          createdAt: today,
        ),
      ),
      throwsA(
        isA<PetOnboardingValidationFailure>().having(
          (PetOnboardingValidationFailure failure) => failure.issues,
          'issues',
          contains(PetOnboardingIssue.otherTypeLabelRequired),
        ),
      ),
    );

    final created = await createPet(
      _command(
        accountId: 'account-a',
        petId: 'pet-a',
        input: const PetOnboardingInput(
          name: 'Mochi',
          type: PetType.other,
          customTypeLabel: ' Hedgehog ',
        ),
        createdAt: today,
      ),
    );
    expect(created.pet.type, PetType.other);
    expect(created.pet.customTypeLabel, 'Hedgehog');
    expect(created.membership.role, PetMembershipRole.owner);
    expect(created.firstMemory.petId, created.pet.id);
  });

  test('rejects birthday and first-met dates in the future', () async {
    final input = PetOnboardingInput(
      name: 'Mochi',
      type: PetType.cat,
      birthday: today.add(const Duration(days: 1)),
      firstMetDate: today.add(const Duration(days: 2)),
    );

    await expectLater(
      createPet(
        _command(
          accountId: 'account-a',
          petId: 'pet-a',
          input: input,
          createdAt: today,
        ),
      ),
      throwsA(
        isA<PetOnboardingValidationFailure>().having(
          (PetOnboardingValidationFailure failure) => failure.issues,
          'issues',
          containsAll(<PetOnboardingIssue>[
            PetOnboardingIssue.birthdayInFuture,
            PetOnboardingIssue.firstMetDateInFuture,
          ]),
        ),
      ),
    );
  });

  test('profile update keeps pet type immutable', () async {
    await createPet(
      _command(
        accountId: 'account-a',
        petId: 'pet-a',
        input: const PetOnboardingInput(name: 'Mochi', type: PetType.cat),
        createdAt: today,
      ),
    );
    final update = UpdatePetProfile(repository);

    await expectLater(
      update(
        accountId: 'account-a',
        petId: 'pet-a',
        name: 'Mochi Cat',
        requestedType: PetType.dog,
        updatedAt: today.add(const Duration(hours: 1)),
      ),
      throwsA(isA<PetTypeImmutableFailure>()),
    );
    final unchanged = (await repository.listActivePets('account-a')).single;
    expect(unchanged.name, 'Mochi');
    expect(unchanged.type, PetType.cat);
  });

  test('multiple pets remain isolated by membership and account', () async {
    await createPet(
      _command(
        accountId: 'account-a',
        petId: 'pet-a1',
        input: const PetOnboardingInput(name: 'Mochi', type: PetType.cat),
        createdAt: today,
      ),
    );
    await createPet(
      _command(
        accountId: 'account-a',
        petId: 'pet-a2',
        input: const PetOnboardingInput(name: 'Pudding', type: PetType.dog),
        createdAt: today.add(const Duration(minutes: 1)),
      ),
    );
    await createPet(
      _command(
        accountId: 'account-b',
        petId: 'pet-b1',
        input: const PetOnboardingInput(name: 'Luna', type: PetType.rabbit),
        createdAt: today.add(const Duration(minutes: 2)),
      ),
    );

    expect(
      (await ListActivePets(repository)(
        'account-a',
      )).map((PetProfile pet) => pet.id),
      <String>['pet-a1', 'pet-a2'],
    );
    expect(
      (await ListActivePets(repository)(
        'account-b',
      )).map((PetProfile pet) => pet.id),
      <String>['pet-b1'],
    );
    await expectLater(
      UpdatePetProfile(repository)(
        accountId: 'account-b',
        petId: 'pet-a1',
        name: 'Wrong account edit',
        updatedAt: today.add(const Duration(hours: 1)),
      ),
      throwsA(isA<PetAccessDeniedFailure>()),
    );
  });

  test(
    'soft delete hides a pet for seven days and restore preserves identity',
    () async {
      final created = await createPet(
        _command(
          accountId: 'account-a',
          petId: 'pet-a',
          input: const PetOnboardingInput(name: 'Mochi', type: PetType.cat),
          createdAt: today,
        ),
      );
      final deletedAt = today.add(const Duration(hours: 2));

      final deleted = await SoftDeletePet(repository)(
        accountId: 'account-a',
        petId: 'pet-a',
        deletedAt: deletedAt,
      );

      expect(await repository.listActivePets('account-a'), isEmpty);
      expect(deleted.status, PetLifecycleStatus.softDeleted);
      expect(deleted.deletionExpiresAt, deletedAt.add(const Duration(days: 7)));
      expect(deleted.recoveryDaysRemaining(deletedAt), 7);
      expect(
        await ListRecoverableDeletedPets(repository)(
          accountId: 'account-a',
          at: deletedAt.add(const Duration(days: 1)),
        ),
        hasLength(1),
      );
      expect(
        await repository.listRecoverableDeletedPets(
          accountId: 'account-b',
          at: deletedAt,
        ),
        isEmpty,
      );

      final restored = await RestorePet(repository)(
        accountId: 'account-a',
        petId: 'pet-a',
        restoredAt: deletedAt.add(const Duration(days: 6)),
      );
      expect(restored.status, PetLifecycleStatus.active);
      expect(restored.createdAt, created.pet.createdAt);
      expect(restored.deletedAt, isNull);
      expect((await repository.listActivePets('account-a')).single.id, 'pet-a');
    },
  );

  test('expired deleted pets are excluded and cannot be restored', () async {
    await createPet(
      _command(
        accountId: 'account-a',
        petId: 'pet-a',
        input: const PetOnboardingInput(name: 'Mochi', type: PetType.cat),
        createdAt: today,
      ),
    );
    await repository.softDeletePet(
      accountId: 'account-a',
      petId: 'pet-a',
      deletedAt: today,
    );
    final expiredAt = today.add(const Duration(days: 7));

    expect(
      await repository.listRecoverableDeletedPets(
        accountId: 'account-a',
        at: expiredAt,
      ),
      isEmpty,
    );
    await expectLater(
      repository.restorePet(
        accountId: 'account-a',
        petId: 'pet-a',
        restoredAt: expiredAt,
      ),
      throwsA(isA<PetDeletionExpiredFailure>()),
    );
    expect(await repository.listActivePets('account-a'), isEmpty);
  });
}

InitializePetJournalCommand _command({
  required String accountId,
  required String petId,
  required PetOnboardingInput input,
  required DateTime createdAt,
}) {
  return InitializePetJournalCommand(
    accountId: accountId,
    petId: petId,
    firstMemoryId: 'first-memory-$petId',
    input: input,
    createdAt: createdAt,
  );
}
