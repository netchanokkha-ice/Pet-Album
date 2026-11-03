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
        await (_database.select(_database.onboardingDrafts)
              ..where(
                (OnboardingDrafts table) => table.accountId.equals(accountId),
              )
              ..orderBy(<OrderClauseGenerator<OnboardingDrafts>>[
                (OnboardingDrafts table) => OrderingTerm.desc(table.updatedAt),
              ])
              ..limit(1))
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
      question: _questionFromWire(decoded['question'] as String?),
      name: decoded['name'] as String? ?? '',
      type: _typeFromWire(decoded['type'] as String?),
      customTypeLabel: decoded['customTypeLabel'] as String?,
      profileImagePath: decoded['profileImagePath'] as String?,
      profileImageBytes: switch (decoded['profileImageBase64']) {
        final String value when value.isNotEmpty => base64Decode(value),
        _ => null,
      },
      profileImageFileName: decoded['profileImageFileName'] as String?,
      profileImageMimeType: decoded['profileImageMimeType'] as String?,
      birthday: _dateFromWire(decoded['birthday'] as String?),
      firstMetDate: _dateFromWire(decoded['firstMetDate'] as String?),
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> save(PetOnboardingDraft draft) async {
    final payload = jsonEncode(<String, Object?>{
      'question': draft.resolvedQuestion.name,
      'name': draft.name,
      'type': draft.type?.name,
      'customTypeLabel': draft.customTypeLabel,
      'profileImagePath': draft.profileImagePath,
      'profileImageBase64': draft.profileImageBytes == null
          ? null
          : base64Encode(draft.profileImageBytes!),
      'profileImageFileName': draft.profileImageFileName,
      'profileImageMimeType': draft.profileImageMimeType,
      'birthday': draft.birthday?.toIso8601String(),
      'firstMetDate': draft.firstMetDate?.toIso8601String(),
    });
    await _database
        .into(_database.onboardingDrafts)
        .insertOnConflictUpdate(
          OnboardingDraftsCompanion.insert(
            accountId: draft.accountId,
            id: draft.id,
            currentStep: Value<int>(draft.step.index),
            payloadJson: Value<String>(payload),
            createdAt: draft.updatedAt,
            updatedAt: draft.updatedAt,
          ),
        );
  }

  @override
  Future<void> clear(String accountId) async {
    await (_database.delete(
          _database.onboardingDrafts,
        )..where((OnboardingDrafts table) => table.accountId.equals(accountId)))
        .go();
  }

  PetType? _typeFromWire(String? value) {
    if (value == null) return null;
    return PetType.values
        .where((PetType type) => type.name == value)
        .firstOrNull;
  }

  PetOnboardingQuestion? _questionFromWire(String? value) {
    if (value == null) return null;
    return PetOnboardingQuestion.values
        .where((PetOnboardingQuestion question) => question.name == value)
        .firstOrNull;
  }

  DateTime? _dateFromWire(String? value) {
    return value == null ? null : DateTime.tryParse(value);
  }
}
