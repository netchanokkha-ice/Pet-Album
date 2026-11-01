import '../database/pawlum_database.dart';
import '../media/app_private_media_storage.dart';
import '../sync/sync_operation.dart';

enum SignOutCleanupChoice { keepLocalWork, discardLocalWork }

enum SignOutCleanupStatus { blocked, retained, cleared }

class SignOutCleanupAssessment {
  const SignOutCleanupAssessment({
    required this.onboardingDraftCount,
    required this.memoryDraftCount,
    required this.unsyncedMediaCount,
    required this.pendingOperationCount,
    required this.privateCacheRowCount,
  });

  final int onboardingDraftCount;
  final int memoryDraftCount;
  final int unsyncedMediaCount;
  final int pendingOperationCount;
  final int privateCacheRowCount;

  bool get hasUnsyncedWork =>
      onboardingDraftCount > 0 ||
      memoryDraftCount > 0 ||
      unsyncedMediaCount > 0 ||
      pendingOperationCount > 0;
}

class SignOutCleanupResult {
  const SignOutCleanupResult({required this.status, required this.assessment});

  final SignOutCleanupStatus status;
  final SignOutCleanupAssessment assessment;
}

class AccountPrivateDataCleaner {
  const AccountPrivateDataCleaner(this._database, this._mediaStorage);

  final PawlumDatabase _database;
  final AppPrivateMediaStorage _mediaStorage;

  Future<SignOutCleanupAssessment> assess(String accountId) async {
    final onboardingDrafts =
        await (_database.select(_database.onboardingDrafts)..where(
              (OnboardingDrafts table) => table.accountId.equals(accountId),
            ))
            .get();
    final memoryDrafts = await (_database.select(
      _database.memoryDrafts,
    )..where((MemoryDrafts table) => table.accountId.equals(accountId))).get();
    final media =
        await (_database.select(_database.localMediaReferences)..where(
              (LocalMediaReferences table) => table.accountId.equals(accountId),
            ))
            .get();
    final operations =
        await (_database.select(_database.syncOperations)..where(
              (SyncOperations table) => table.accountId.equals(accountId),
            ))
            .get();
    final summaries =
        await (_database.select(_database.cachedPublishedSummaries)..where(
              (CachedPublishedSummaries table) =>
                  table.accountId.equals(accountId),
            ))
            .get();
    final unsyncedMediaCount = media.where((LocalMediaReferenceRow row) {
      return row.uploadState != 'uploaded' && row.uploadState != 'removed';
    }).length;
    final pendingOperationCount = operations.where((SyncOperationRow row) {
      return row.status != SyncOperationStatus.completed.wireName;
    }).length;

    return SignOutCleanupAssessment(
      onboardingDraftCount: onboardingDrafts.length,
      memoryDraftCount: memoryDrafts.length,
      unsyncedMediaCount: unsyncedMediaCount,
      pendingOperationCount: pendingOperationCount,
      privateCacheRowCount: media.length + summaries.length,
    );
  }

  Future<SignOutCleanupResult> cleanupForSignOut({
    required String accountId,
    SignOutCleanupChoice? choice,
  }) async {
    final assessment = await assess(accountId);
    if (assessment.hasUnsyncedWork && choice == null) {
      return SignOutCleanupResult(
        status: SignOutCleanupStatus.blocked,
        assessment: assessment,
      );
    }
    if (assessment.hasUnsyncedWork &&
        choice == SignOutCleanupChoice.keepLocalWork) {
      return SignOutCleanupResult(
        status: SignOutCleanupStatus.retained,
        assessment: assessment,
      );
    }

    await _mediaStorage.deleteAccountMedia(accountId);
    await _database.transaction(() async {
      await (_database.delete(
            _database.syncOperations,
          )..where((SyncOperations table) => table.accountId.equals(accountId)))
          .go();
      await (_database.delete(_database.localMediaReferences)..where(
            (LocalMediaReferences table) => table.accountId.equals(accountId),
          ))
          .go();
      await (_database.delete(
        _database.memoryDrafts,
      )..where((MemoryDrafts table) => table.accountId.equals(accountId))).go();
      await (_database.delete(_database.onboardingDrafts)..where(
            (OnboardingDrafts table) => table.accountId.equals(accountId),
          ))
          .go();
      await (_database.delete(_database.cachedPublishedSummaries)..where(
            (CachedPublishedSummaries table) =>
                table.accountId.equals(accountId),
          ))
          .go();
    });

    return SignOutCleanupResult(
      status: SignOutCleanupStatus.cleared,
      assessment: assessment,
    );
  }
}
