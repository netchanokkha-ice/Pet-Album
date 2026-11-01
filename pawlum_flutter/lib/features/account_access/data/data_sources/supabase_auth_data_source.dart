import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthUserSnapshot {
  const SupabaseAuthUserSnapshot({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.providers,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;
  final bool emailVerified;
  final Set<String> providers;
}

class SupabaseAuthSessionSnapshot {
  const SupabaseAuthSessionSnapshot({
    required this.user,
    required this.startedAt,
    required this.expiresAt,
  });

  final SupabaseAuthUserSnapshot user;
  final DateTime startedAt;
  final DateTime expiresAt;
}

class SupabaseSignUpSnapshot {
  const SupabaseSignUpSnapshot({required this.user, this.session});

  final SupabaseAuthUserSnapshot user;
  final SupabaseAuthSessionSnapshot? session;
}

abstract interface class SupabaseAuthDataSource {
  Stream<SupabaseAuthSessionSnapshot> get authSessions;

  Future<SupabaseSignUpSnapshot> signUp({
    required String email,
    required String password,
  });

  Future<SupabaseAuthSessionSnapshot> signInWithPassword({
    required String email,
    required String password,
  });

  Future<SupabaseAuthSessionSnapshot?> restoreSession();

  Future<void> resendVerification({required String email});

  Future<void> requestPasswordRecovery({required String email});

  Future<void> signOut();

  Future<void> beginGoogleSignIn({required Uri redirectTo});
}

class SupabaseAuthSnapshotMapper {
  const SupabaseAuthSnapshotMapper({required this.now});

  final DateTime Function() now;

  SupabaseAuthSessionSnapshot mapSession(Session session) {
    final mappedAt = now().toUtc();
    final expiresAtSeconds = session.expiresAt;
    final expiresAt = expiresAtSeconds == null
        ? mappedAt.add(Duration(seconds: session.expiresIn ?? 0))
        : DateTime.fromMillisecondsSinceEpoch(
            expiresAtSeconds * 1000,
            isUtc: true,
          );
    final startedAt = session.expiresIn == null
        ? mappedAt
        : expiresAt.subtract(Duration(seconds: session.expiresIn!));
    return SupabaseAuthSessionSnapshot(
      user: mapUser(session.user),
      startedAt: startedAt,
      expiresAt: expiresAt,
    );
  }

  SupabaseAuthUserSnapshot mapUser(User user) {
    final metadata = user.userMetadata;
    final displayName = metadata?['display_name'] ?? metadata?['full_name'];
    return SupabaseAuthUserSnapshot(
      id: user.id,
      email: user.email ?? '',
      displayName: displayName is String ? displayName : null,
      emailVerified: user.emailConfirmedAt != null,
      providers:
          user.identities?.map((identity) => identity.provider).toSet() ??
          const <String>{'email'},
    );
  }
}

class SupabaseAuthDataSourceClient implements SupabaseAuthDataSource {
  SupabaseAuthDataSourceClient(this._client, {required DateTime Function() now})
    : _mapper = SupabaseAuthSnapshotMapper(now: now);

  final SupabaseClient _client;
  final SupabaseAuthSnapshotMapper _mapper;

  @override
  Stream<SupabaseAuthSessionSnapshot> get authSessions async* {
    await for (final state in _client.auth.onAuthStateChange) {
      final session = state.session;
      if (session != null) yield _mapper.mapSession(session);
    }
  }

  @override
  Future<SupabaseSignUpSnapshot> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Signup response did not include a user.');
    }
    return SupabaseSignUpSnapshot(
      user: _mapper.mapUser(user),
      session: response.session == null
          ? null
          : _mapper.mapSession(response.session!),
    );
  }

  @override
  Future<SupabaseAuthSessionSnapshot> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final session = response.session;
    if (session == null) {
      throw const AuthException('Signin response did not include a session.');
    }
    return _mapper.mapSession(session);
  }

  @override
  Future<SupabaseAuthSessionSnapshot?> restoreSession() async {
    final session = _client.auth.currentSession;
    return session == null ? null : _mapper.mapSession(session);
  }

  @override
  Future<void> resendVerification({required String email}) async {
    await _client.auth.resend(email: email, type: OtpType.signup);
  }

  @override
  Future<void> requestPasswordRecovery({required String email}) =>
      _client.auth.resetPasswordForEmail(email);

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> beginGoogleSignIn({required Uri redirectTo}) async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : redirectTo.toString(),
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }
}
