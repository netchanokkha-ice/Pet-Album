import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/pawlum_database.dart';
import '../../domain/entities/pet_models.dart';
import '../../domain/entities/pet_onboarding_draft.dart';
import '../../domain/repositories/pet_onboarding_draft_repository.dart';

class DriftPetOnboardingDraftRepository
    implements PetOnboardingDraftRepository {
  const DriftPetOnboardingDraftRepository(this._database);

  final PawlumDatabase _database;

  @override
  Future<PetOnboardingDraft?> load(String accountId) async {
    final row =
        await (_database.select(_database.onboardingDrafts)..where(
              (OnboardingDrafts table) =>
                  table.accountId.equals(accountId) & table.id.equals('active'),
            ))
            .getSingleOrNull();
    if (row == null) return null;

    final Object? decoded = jsonDecode(row.payloadJson);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException(
        'Onboarding draft payload must be an object.',
      );
    }
    return PetOnboardingDraft(
      accountId: row.accountId,
      id: row.id,
      step: PetOnboardingStep.values[row.currentStep],
      name: decoded['name'] as String? ?? '',
      type: _typeFromWire(decoded['type'] as String?),
      customTypeLabel: decoded['customTypeLabel'] as String?,
      profileImagePath: decoded['profileImagePath'] as String?,
      birthday: _dateFromWire(decoded['birthday'] as String?),
      firstMetDate: _dateFromWire(decoded['firstMetDate'] as String?),
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> save(PetOnboardingDraft draft) async {
    final payload = jsonEncode(<String, Object?>{
      'name': draft.name,
      'type': draft.type?.name,
      'customTypeLabel': draft.customTypeLabel,
      'profileImagePath': draft.profileImagePath,
      'birthday': draft.birthday?.toIso8601String(),
      'firstMetDate': draft.firstMetDate?.toIso8601String(),
    });
    await _database
        .into(_database.onboardingDrafts)
        .insertOnConflictUpdate(
          OnboardingDraftsCompanion.insert(
            accountId: draft.accountId,
            id: 'active',
            currentStep: Value<int>(draft.step.index),
            payloadJson: Value<String>(payload),
            createdAt: draft.updatedAt,
            updatedAt: draft.updatedAt,
          ),
        );
  }

  @override
  Future<void> clear(String accountId) async {
    await (_database.delete(_database.onboardingDrafts)..where(
          (OnboardingDrafts table) =>
              table.accountId.equals(accountId) & table.id.equals('active'),
        ))
        .go();
  }

  PetType? _typeFromWire(String? value) {
    if (value == null) return null;
    return PetType.values
        .where((PetType type) => type.name == value)
        .firstOrNull;
  }

  DateTime? _dateFromWire(String? value) {
    return value == null ? null : DateTime.tryParse(value);
  }
}
