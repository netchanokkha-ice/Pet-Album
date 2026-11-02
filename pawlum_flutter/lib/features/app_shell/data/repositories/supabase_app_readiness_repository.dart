import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../pet_profiles/domain/repositories/pet_onboarding_draft_repository.dart';
import '../../domain/entities/app_readiness.dart';
import '../../domain/repositories/app_readiness_repository.dart';

class SupabaseAppReadinessRepository implements AppReadinessRepository {
  const SupabaseAppReadinessRepository(this._client, this._draftRepository);

  final SupabaseClient _client;
  final PetOnboardingDraftRepository _draftRepository;

  @override
  Future<AppReadiness> load() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const AppReadiness(
        isAuthenticated: false,
        petCount: 0,
        pendingDraftCount: 0,
      );
    }

    final rowsFuture = _client
        .from('pets')
        .select('id')
        .isFilter('deleted_at', null);
    final draftFuture = _draftRepository.load(user.id);
    final rows = await rowsFuture;
    final draft = await draftFuture;
    return AppReadiness(
      isAuthenticated: true,
      petCount: rows.length,
      pendingDraftCount: draft == null ? 0 : 1,
    );
  }
}
