import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/core/database/pawlum_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  late Directory tempDirectory;
  late File databaseFile;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('pawlum-drift-test-');
    databaseFile = File(
      '${tempDirectory.path}${Platform.pathSeparator}pawlum.sqlite',
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'persists every account-scoped store across a database restart',
    () async {
      final now = DateTime.utc(2026, 10, 31, 10);
      final firstRun = _openDatabase(databaseFile);

      await firstRun
          .into(firstRun.onboardingDrafts)
          .insert(
            OnboardingDraftsCompanion.insert(
              accountId: 'account-a',
              id: 'onboarding-1',
              currentStep: const Value<int>(2),
              payloadJson: const Value<String>('{"petName":"Mochi"}'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await firstRun
          .into(firstRun.memoryDrafts)
          .insert(
            MemoryDraftsCompanion.insert(
              accountId: 'account-a',
              id: 'draft-1',
              memoryId: 'memory-1',
              draftKind: 'edit_memory',
              basePublishedVersionId: const Value<String>('version-1'),
              baseRemoteRevision: const Value<String>('revision-4'),
              currentStep: const Value<int>(3),
              payloadJson: const Value<String>('{"title":"First walk"}'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await firstRun
          .into(firstRun.localMediaReferences)
          .insert(
            LocalMediaReferencesCompanion.insert(
              accountId: 'account-a',
              id: 'media-1',
              ownerDraftType: 'memory',
              ownerDraftId: 'draft-1',
              localPath: '/private/account-a/media-1.jpg',
              mediaType: 'image',
              checksum: const Value<String>('sha256-fixture'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await firstRun
          .into(firstRun.cachedPublishedSummaries)
          .insert(
            CachedPublishedSummariesCompanion.insert(
              accountId: 'account-a',
              memoryId: 'memory-1',
              publishedVersionId: 'version-1',
              petIdsJson: const Value<String>('["pet-1"]'),
              title: 'First walk',
              memoryDate: now,
              remoteRevision: 'revision-4',
              cachedAt: now,
              lastAccessedAt: now,
            ),
          );
      await firstRun
          .into(firstRun.syncOperations)
          .insert(
            SyncOperationsCompanion.insert(
              accountId: 'account-a',
              id: 'operation-1',
              aggregateType: 'memory',
              aggregateId: 'memory-1',
              operationType: 'publish',
              idempotencyKey: 'account-a:memory-1:publish:version-1',
              dependencyIdsJson: const Value<String>('["upload-media-1"]'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await firstRun
          .into(firstRun.appPreferences)
          .insert(
            AppPreferencesCompanion.insert(
              key: 'language_code',
              value: 'th',
              updatedAt: now,
            ),
          );

      // Composite keys allow stable client IDs to coexist without exposing one
      // account's rows through another account scope.
      await firstRun
          .into(firstRun.onboardingDrafts)
          .insert(
            OnboardingDraftsCompanion.insert(
              accountId: 'account-b',
              id: 'onboarding-1',
              payloadJson: const Value<String>('{"petName":"Luna"}'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await firstRun.close();

      final secondRun = _openDatabase(databaseFile);
      final onboarding =
          await (secondRun.select(secondRun.onboardingDrafts)..where(
                (OnboardingDrafts table) => table.accountId.equals('account-a'),
              ))
              .getSingle();
      final memoryDraft =
          await (secondRun.select(secondRun.memoryDrafts)..where(
                (MemoryDrafts table) => table.accountId.equals('account-a'),
              ))
              .getSingle();
      final media =
          await (secondRun.select(secondRun.localMediaReferences)..where(
                (LocalMediaReferences table) =>
                    table.accountId.equals('account-a'),
              ))
              .getSingle();
      final summary =
          await (secondRun.select(secondRun.cachedPublishedSummaries)..where(
                (CachedPublishedSummaries table) =>
                    table.accountId.equals('account-a'),
              ))
              .getSingle();
      final operation =
          await (secondRun.select(secondRun.syncOperations)..where(
                (SyncOperations table) => table.accountId.equals('account-a'),
              ))
              .getSingle();
      final preference = await secondRun
          .select(secondRun.appPreferences)
          .getSingle();

      expect(onboarding.payloadJson, '{"petName":"Mochi"}');
      expect(memoryDraft.baseRemoteRevision, 'revision-4');
      expect(media.localPath, '/private/account-a/media-1.jpg');
      expect(summary.title, 'First walk');
      expect(operation.dependencyIdsJson, '["upload-media-1"]');
      expect(preference.value, 'th');
      expect(
        await secondRun.select(secondRun.onboardingDrafts).get(),
        hasLength(2),
      );

      await secondRun.close();
    },
  );

  test('migrates v1 to v3 without losing pending local work', () async {
    final now = DateTime.utc(2026, 10, 31, 11);
    final versionOne = _openDatabase(databaseFile);
    await versionOne
        .into(versionOne.onboardingDrafts)
        .insert(
          OnboardingDraftsCompanion.insert(
            accountId: 'account-a',
            id: 'onboarding-legacy',
            currentStep: const Value<int>(1),
            payloadJson: const Value<String>('{"petName":"Legacy"}'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await versionOne
        .into(versionOne.syncOperations)
        .insert(
          SyncOperationsCompanion.insert(
            accountId: 'account-a',
            id: 'operation-legacy',
            aggregateType: 'pet',
            aggregateId: 'pet-legacy',
            operationType: 'initialize',
            idempotencyKey: 'account-a:pet-legacy:initialize',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await versionOne.close();

    _downgradeFixtureToVersionOne(databaseFile);

    final upgraded = _openDatabase(databaseFile);
    final schemaVersion = await upgraded
        .customSelect('PRAGMA user_version')
        .getSingle();
    final legacyDraft = await upgraded
        .select(upgraded.onboardingDrafts)
        .getSingle();
    final legacyOperation = await upgraded
        .select(upgraded.syncOperations)
        .getSingle();
    final cacheIndexes = await upgraded
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name LIKE 'published_summaries_account_%' ORDER BY name",
        )
        .get();

    expect(schemaVersion.read<int>('user_version'), 3);
    expect(legacyDraft.payloadJson, '{"petName":"Legacy"}');
    expect(legacyOperation.idempotencyKey, 'account-a:pet-legacy:initialize');
    expect(
      cacheIndexes.map((QueryRow row) => row.read<String>('name')),
      <String>[
        'published_summaries_account_accessed',
        'published_summaries_account_memory_date',
      ],
    );

    await upgraded
        .into(upgraded.cachedPublishedSummaries)
        .insert(
          CachedPublishedSummariesCompanion.insert(
            accountId: 'account-a',
            memoryId: 'memory-after-upgrade',
            publishedVersionId: 'version-after-upgrade',
            title: 'Still safe',
            memoryDate: now,
            remoteRevision: 'revision-1',
            cachedAt: now,
            lastAccessedAt: now,
          ),
        );
    expect(
      await upgraded.select(upgraded.cachedPublishedSummaries).getSingle(),
      isA<CachedPublishedSummaryRow>(),
    );
    await upgraded
        .into(upgraded.appPreferences)
        .insert(
          AppPreferencesCompanion.insert(
            key: 'language_code',
            value: 'en',
            updatedAt: now,
          ),
        );
    expect(
      await upgraded.select(upgraded.appPreferences).getSingle(),
      isA<AppPreferenceRow>(),
    );

    await upgraded.close();
  });
}

PawlumDatabase _openDatabase(File file) {
  return PawlumDatabase.forTesting(NativeDatabase(file));
}

void _downgradeFixtureToVersionOne(File file) {
  final rawDatabase = sqlite.sqlite3.open(file.path);
  try {
    rawDatabase.execute(
      'DROP INDEX IF EXISTS published_summaries_account_accessed',
    );
    rawDatabase.execute(
      'DROP INDEX IF EXISTS published_summaries_account_memory_date',
    );
    rawDatabase.execute('DROP TABLE cached_published_summaries');
    rawDatabase.execute('PRAGMA user_version = 1');
  } finally {
    rawDatabase.close();
  }
}
