import '../entities/timeline_models.dart';

abstract interface class TimelineRepository {
  Future<TimelinePage> loadPage({
    required String petId,
    TimelineCursor? after,
    int limit = 20,
  });
}
