import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:pawlum/core/database/pawlum_database.dart';
import 'package:pawlum/core/media/app_private_media_storage.dart';
import 'package:pawlum/core/privacy/account_private_data_cleaner.dart';
import 'package:pawlum/core/sync/sync_operation.dart';

void main() {
  late Directory tempDirectory;
  late Directory privateRoot;
  late File databaseFile;
  late PawlumDatabase database;
  late AppPrivateMediaStorage mediaStorage;
  late AccountPrivateDataCleaner cleaner;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'pawlum-private-test-',
    );
    privateRoot = Directory(path.join(tempDirectory.path, 'app-support'));
    databaseFile = File(path.join(tempDirectory.path, 'pawlum.sqlite'));
    database = PawlumDatabase.forTesting(NativeDatabase(databaseFile));
    mediaStorage = AppPrivateMediaStorage(
      rootDirectoryProvider: () async => privateRoot,
    );
    cleaner = AccountPrivateDataCleaner(database, mediaStorage);
  });

  tearDown(() async {
    await database.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('imports selected media into an account-scoped private path', () async {
    final source = File(path.join(tempDirectory.path, 'selected image.jpg'));
    await source.writeAsBytes(<int>[1, 2, 3, 4]);

    final stored = await mediaStorage.importFile(
      accountId: 'account/../a',
      mediaId: '../media-1',
      source: source,
    );
    await source.delete();

    final normalizedRoot = path.normalize(path.absolute(privateRoot.path));
    final normalizedStored = path.normalize(path.absolute(stored.filePath));
    expect(path.isWithin(normalizedRoot, normalizedStored), isTrue);
    expect(await File(stored.filePath).readAsBytes(), <int>[1, 2, 3, 4]);
    expect(path.extension(stored.filePath), '.jpg');
  });

  test(
    'safe sign-out removes only the signed-in account private cache',
    () async {
      final now = DateTime.utc(2026, 10, 31, 16);
      final accountAFile = await _importFixture(
        mediaStorage,
        tempDirectory,
        accountId: 'account-a',
        mediaId: 'media-a',
        byte: 1,
      );
      final accountBFile = await _importFixture(
        mediaStorage,
        tempDirectory,
        accountId: 'account-b',
        mediaId: 'media-b',
        byte: 2,
      );
      await _insertUploadedCache(
        database,
        accountId: 'account-a',
        mediaId: 'media-a',
        localPath: accountAFile.filePath,
        now: now,
      );
      await _insertUploadedCache(
        database,
        accountId: 'account-b',
        mediaId: 'media-b',
        localPath: accountBFile.filePath,
        now: now,
      );

      final assessment = await cleaner.assess('account-a');
      final result = await cleaner.cleanupForSignOut(accountId: 'account-a');

      expect(assessment.hasUnsyncedWork, isFalse);
      expect(assessment.privateCacheRowCount, 2);
      expect(result.status, SignOutCleanupStatus.cleared);
      expect(await File(accountAFile.filePath).exists(), isFalse);
      expect(await File(accountBFile.filePath).exists(), isTrue);
      expect(
        await (database.select(database.localMediaReferences)..where(
              (LocalMediaReferences table) =>
                  table.accountId.equals('account-a'),
            ))
            .get(),
        isEmpty,
      );
      expect(
        await (database.select(database.localMediaReferences)..where(
              (LocalMediaReferences table) =>
                  table.accountId.equals('account-b'),
            ))
            .get(),
        hasLength(1),
      );
    },
  );

  test(
    'unsynced work blocks cleanup until keep or discard is explicit',
    () async {
      final now = DateTime.utc(2026, 10, 31, 17);
      final stored = await _importFixture(
        mediaStorage,
        tempDirectory,
        accountId: 'account-a',
        mediaId: 'media-a',
        byte: 3,
      );
      await database
          .into(database.memoryDrafts)
          .insert(
            MemoryDraftsCompanion.insert(
              accountId: 'account-a',
              id: 'draft-a',
              memoryId: 'memory-a',
              draftKind: 'new_memory',
              payloadJson: const Value<String>('{"title":"Do not lose me"}'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database
          .into(database.localMediaReferences)
          .insert(
            LocalMediaReferencesCompanion.insert(
              accountId: 'account-a',
              id: 'media-a',
              ownerDraftType: 'memory',
              ownerDraftId: 'draft-a',
              localPath: stored.filePath,
              mediaType: 'image',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database
          .into(database.syncOperations)
          .insert(
            SyncOperationsCompanion.insert(
              accountId: 'account-a',
              id: 'operation-a',
              aggregateType: 'memory',
              aggregateId: 'memory-a',
              operationType: 'publish',
              idempotencyKey: 'operation-a-key',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final blocked = await cleaner.cleanupForSignOut(accountId: 'account-a');
      expect(blocked.status, SignOutCleanupStatus.blocked);
      expect(blocked.assessment.memoryDraftCount, 1);
      expect(blocked.assessment.unsyncedMediaCount, 1);
      expect(blocked.assessment.pendingOperationCount, 1);
      expect(await File(stored.filePath).exists(), isTrue);

      final kept = await cleaner.cleanupForSignOut(
        accountId: 'account-a',
        choice: SignOutCleanupChoice.keepLocalWork,
      );
      expect(kept.status, SignOutCleanupStatus.retained);
      expect(await database.select(database.memoryDrafts).get(), hasLength(1));
      expect(await File(stored.filePath).exists(), isTrue);

      final discarded = await cleaner.cleanupForSignOut(
        accountId: 'account-a',
        choice: SignOutCleanupChoice.discardLocalWork,
      );
      expect(discarded.status, SignOutCleanupStatus.cleared);
      expect(await database.select(database.memoryDrafts).get(), isEmpty);
      expect(
        await database.select(database.localMediaReferences).get(),
        isEmpty,
      );
      expect(await database.select(database.syncOperations).get(), isEmpty);
      expect(await File(stored.filePath).exists(), isFalse);
    },
  );
}

Future<StoredPrivateMedia> _importFixture(
  AppPrivateMediaStorage storage,
  Directory tempDirectory, {
  required String accountId,
  required String mediaId,
  required int byte,
}) async {
  final source = File(path.join(tempDirectory.path, '$accountId-$mediaId.jpg'));
  await source.writeAsBytes(<int>[byte]);
  return storage.importFile(
    accountId: accountId,
    mediaId: mediaId,
    source: source,
  );
}

Future<void> _insertUploadedCache(
  PawlumDatabase database, {
  required String accountId,
  required String mediaId,
  required String localPath,
  required DateTime now,
}) async {
  await database
      .into(database.localMediaReferences)
      .insert(
        LocalMediaReferencesCompanion.insert(
          accountId: accountId,
          id: mediaId,
          ownerDraftType: 'published_cache',
          ownerDraftId: 'memory-$mediaId',
          localPath: localPath,
          mediaType: 'image',
          uploadState: const Value<String>('uploaded'),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database
      .into(database.cachedPublishedSummaries)
      .insert(
        CachedPublishedSummariesCompanion.insert(
          accountId: accountId,
          memoryId: 'memory-$mediaId',
          publishedVersionId: 'version-$mediaId',
          title: 'Cached memory',
          memoryDate: now,
          remoteRevision: 'revision-1',
          cachedAt: now,
          lastAccessedAt: now,
        ),
      );
  await database
      .into(database.syncOperations)
      .insert(
        SyncOperationsCompanion.insert(
          accountId: accountId,
          id: 'completed-$mediaId',
          aggregateType: 'media',
          aggregateId: mediaId,
          operationType: 'upload',
          idempotencyKey: 'completed-$accountId-$mediaId',
          status: Value<String>(SyncOperationStatus.completed.wireName),
          createdAt: now,
          updatedAt: now,
        ),
      );
}
