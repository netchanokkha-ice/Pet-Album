import '../../domain/entities/app_readiness.dart';
import '../../domain/repositories/app_readiness_repository.dart';

class FakeAppReadinessRepository implements AppReadinessRepository {
  FakeAppReadinessRepository({
    this.readiness = const AppReadiness(
      isAuthenticated: false,
      petCount: 0,
      pendingDraftCount: 0,
    ),
    this.loadError,
    this.loadDelay = Duration.zero,
  });

  final AppReadiness readiness;
  final Object? loadError;
  final Duration loadDelay;

  @override
  Future<AppReadiness> load() async {
    if (loadDelay > Duration.zero) await Future<void>.delayed(loadDelay);
    if (loadError != null) throw loadError!;
    return readiness;
  }
}
