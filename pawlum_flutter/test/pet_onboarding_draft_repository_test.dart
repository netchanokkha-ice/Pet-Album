import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pawlum/core/database/pawlum_database.dart';
import 'package:pawlum/features/pet_profiles/data/repositories/drift_pet_onboarding_draft_repository.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_models.dart';
import 'package:pawlum/features/pet_profiles/domain/entities/pet_onboarding_draft.dart';

void main() {
  test('Drift onboarding draft survives a database restart', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'pawlum-onboarding-repository-',
    );
    final file = File(path.join(tempDirectory.path, 'pawlum.sqlite'));
    final updatedAt = DateTime.utc(2026, 11, 1, 2);
    var database = PawlumDatabase.forTesting(NativeDatabase(file));
    var repository = DriftPetOnboardingDraftRepository(database);

    await repository.save(
      PetOnboardingDraft(
        accountId: 'account-a',
        id: '4d4ef86d-aa02-464c-b5f9-2e4399e0d210',
        step: PetOnboardingStep.photo,
        name: 'Mochi',
        type: PetType.cat,
        birthday: DateTime.utc(2024, 5, 10),
        profileImageBytes: Uint8List.fromList(<int>[1, 2, 3, 4]),
        profileImageFileName: 'mochi.png',
        profileImageMimeType: 'image/png',
        updatedAt: updatedAt,
      ),
    );
    await database.close();

    database = PawlumDatabase.forTesting(NativeDatabase(file));
    repository = DriftPetOnboardingDraftRepository(database);
    final restored = await repository.load('account-a');

    expect(restored?.step, PetOnboardingStep.photo);
    expect(restored?.resolvedQuestion, PetOnboardingQuestion.photo);
    expect(restored?.id, '4d4ef86d-aa02-464c-b5f9-2e4399e0d210');
    expect(restored?.name, 'Mochi');
    expect(restored?.type, PetType.cat);
    expect(restored?.birthday, DateTime.utc(2024, 5, 10));
    expect(restored?.profileImageBytes, <int>[1, 2, 3, 4]);
    expect(restored?.profileImageFileName, 'mochi.png');
    expect(restored?.profileImageMimeType, 'image/png');
    expect(await repository.load('account-b'), isNull);

    await repository.clear('account-a');
    expect(await repository.load('account-a'), isNull);
    await database.close();
    await tempDirectory.delete(recursive: true);
  });
}
