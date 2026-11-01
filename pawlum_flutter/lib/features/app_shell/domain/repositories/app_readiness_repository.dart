import '../entities/app_readiness.dart';

abstract interface class AppReadinessRepository {
  Future<AppReadiness> load();
}
