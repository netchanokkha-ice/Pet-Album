import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'pawlum_database.g.dart';

@DataClassName('OnboardingDraftRow')
@TableIndex(name: 'onboarding_drafts_account', columns: {#accountId})
class OnboardingDrafts extends Table {
  TextColumn get accountId => text()();
  TextColumn get id => text()();
  IntColumn get currentStep => integer().withDefault(const Constant(0))();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  TextColumn get remoteRevision => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{accountId, id};
}

@DataClassName('MemoryDraftRow')
@TableIndex(
  name: 'memory_drafts_account_updated',
  columns: {#accountId, #updatedAt},
)
@TableIndex(
  name: 'memory_drafts_account_memory_kind',
  unique: true,
  columns: {#accountId, #memoryId, #draftKind},
)
class MemoryDrafts extends Table {
  TextColumn get accountId => text()();
  TextColumn get id => text()();
  TextColumn get memoryId => text()();
  TextColumn get draftKind => text()();
  TextColumn get basePublishedVersionId => text().nullable()();
  TextColumn get baseRemoteRevision => text().nullable()();
  IntColumn get currentStep => integer().withDefault(const Constant(0))();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{accountId, id};
}

@DataClassName('LocalMediaReferenceRow')
@TableIndex(
  name: 'local_media_account_owner',
  columns: {#accountId, #ownerDraftId},
)
@TableIndex(
  name: 'local_media_account_upload_state',
  columns: {#accountId, #uploadState},
)
class LocalMediaReferences extends Table {
  TextColumn get accountId => text()();
  TextColumn get id => text()();
  TextColumn get ownerDraftType => text()();
  TextColumn get ownerDraftId => text()();
  TextColumn get localPath => text()();
  TextColumn get mediaType => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get checksum => text().nullable()();
  TextColumn get uploadState =>
      text().withDefault(const Constant('local_selected'))();
  TextColumn get remoteObjectPath => text().nullable()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{accountId, id};
}

@DataClassName('CachedPublishedSummaryRow')
@TableIndex(
  name: 'published_summaries_account_memory_date',
  columns: {#accountId, #memoryDate},
)
@TableIndex(
  name: 'published_summaries_account_accessed',
  columns: {#accountId, #lastAccessedAt},
)
class CachedPublishedSummaries extends Table {
  TextColumn get accountId => text()();
  TextColumn get memoryId => text()();
  TextColumn get publishedVersionId => text()();
  TextColumn get petIdsJson => text().withDefault(const Constant('[]'))();
  TextColumn get title => text()();
  TextColumn get captionSnippet => text().nullable()();
  DateTimeColumn get memoryDate => dateTime()();
  TextColumn get coverMediaPath => text().nullable()();
  TextColumn get presentationJson => text().withDefault(const Constant('{}'))();
  TextColumn get remoteRevision => text()();
  DateTimeColumn get cachedAt => dateTime()();
  DateTimeColumn get lastAccessedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{accountId, memoryId};
}

@DataClassName('SyncOperationRow')
@TableIndex(
  name: 'sync_operations_account_ready',
  columns: {#accountId, #status, #nextAttemptAt},
)
@TableIndex(
  name: 'sync_operations_account_idempotency',
  unique: true,
  columns: {#accountId, #idempotencyKey},
)
class SyncOperations extends Table {
  TextColumn get accountId => text()();
  TextColumn get id => text()();
  TextColumn get aggregateType => text()();
  TextColumn get aggregateId => text()();
  TextColumn get operationType => text()();
  TextColumn get idempotencyKey => text()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  TextColumn get dependencyIdsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get remoteRevision => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{accountId, id};
}

@DataClassName('AppPreferenceRow')
class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

@DriftDatabase(
  tables: <Type>[
    OnboardingDrafts,
    MemoryDrafts,
    LocalMediaReferences,
    CachedPublishedSummaries,
    SyncOperations,
    AppPreferences,
  ],
)
class PawlumDatabase extends _$PawlumDatabase {
  PawlumDatabase() : super(driftDatabase(name: 'pawlum_journal'));

  PawlumDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) => migrator.createAll(),
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 1) {
        throw StateError('Unsupported Pawlum database schema version: $from');
      }

      if (from < 2) {
        await migrator.createTable(cachedPublishedSummaries);
        await migrator.createIndex(publishedSummariesAccountMemoryDate);
        await migrator.createIndex(publishedSummariesAccountAccessed);
      }

      if (from < 3) {
        await migrator.createTable(appPreferences);
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );
}
