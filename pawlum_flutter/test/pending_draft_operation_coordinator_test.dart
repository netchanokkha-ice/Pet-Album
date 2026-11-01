import 'package:flutter_test/flutter_test.dart';
import 'package:pawlum/features/account_access/data/repositories/in_memory_account_repository.dart';
import 'package:pawlum/features/account_access/domain/entities/account_identity.dart';
import 'package:pawlum/features/account_access/domain/entities/account_session.dart';
import 'package:pawlum/features/account_access/domain/use_cases/pending_draft_operation_coordinator.dart';

void main() {
  test(
    'expired session preserves draft and resumes queued save after reauth',
    () async {
      var now = DateTime.utc(2026, 10, 31, 9);
      final repository = InMemoryAccountRepository(now: () => now);
      var signInRequests = 0;
      var remoteSaveCount = 0;
      const localDraft = 'Mochi found the sunny window.';
      final coordinator = PendingDraftOperationCoordinator(
        repository: repository,
        requestSignIn: () async => signInRequests += 1,
        now: () => now,
      );
      final expiredSession = _session(
        now: now.subtract(const Duration(hours: 2)),
        expiresAt: now.subtract(const Duration(hours: 1)),
      );

      coordinator.start();
      await coordinator.runOrQueue(
        session: expiredSession,
        operation: () async => remoteSaveCount += 1,
      );

      expect(localDraft, 'Mochi found the sunny window.');
      expect(coordinator.hasQueuedOperation, isTrue);
      expect(signInRequests, 1);
      expect(remoteSaveCount, 0);

      now = now.add(const Duration(minutes: 1));
      final refreshedSession = _session(
        now: now,
        expiresAt: now.add(const Duration(hours: 1)),
      );
      repository.emitAuthSession(refreshedSession);
      await Future<void>.delayed(Duration.zero);

      expect(localDraft, 'Mochi found the sunny window.');
      expect(coordinator.hasQueuedOperation, isFalse);
      expect(remoteSaveCount, 1);

      repository.emitAuthSession(refreshedSession);
      await Future<void>.delayed(Duration.zero);
      expect(remoteSaveCount, 1);
      await coordinator.close();
    },
  );
}

AccountSession _session({required DateTime now, required DateTime expiresAt}) {
  return AccountSession(
    account: const AccountIdentity(
      id: 'verified-user',
      email: 'mali@example.com',
      isEmailVerified: true,
      authMethods: <AccountAuthMethod>{AccountAuthMethod.emailPassword},
    ),
    startedAt: now,
    expiresAt: expiresAt,
  );
}
