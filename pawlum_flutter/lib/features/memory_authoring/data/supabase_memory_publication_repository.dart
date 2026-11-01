import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/memory_publication.dart';
import '../domain/repositories/memory_publication_repository.dart';

abstract interface class MemoryPublicationRpcClient {
  Future<Object?> call(String functionName, Map<String, Object?> parameters);
}

class SupabaseMemoryPublicationRpcClient implements MemoryPublicationRpcClient {
  const SupabaseMemoryPublicationRpcClient(this._client);

  final SupabaseClient _client;

  @override
  Future<Object?> call(String functionName, Map<String, Object?> parameters) =>
      _client.rpc(functionName, params: parameters);
}

class SupabaseMemoryPublicationRepository
    implements MemoryPublicationRepository {
  const SupabaseMemoryPublicationRepository(this._rpc);

  final MemoryPublicationRpcClient _rpc;

  @override
  Future<MemoryPublicationResult> publish({
    required String memoryId,
    required String versionId,
  }) async {
    final response = await _rpc.call('publish_memory', <String, Object?>{
      'p_memory_id': memoryId,
      'p_version_id': versionId,
    });
    return _publication(response);
  }

  @override
  Future<MemoryEditDraftReference> beginOrResumeEdit({
    required String memoryId,
    required String proposedVersionId,
  }) async {
    final response = await _rpc.call('begin_memory_edit', <String, Object?>{
      'p_memory_id': memoryId,
      'p_version_id': proposedVersionId,
    });
    final object = _object(response);
    return MemoryEditDraftReference(
      memoryId: _requiredString(object, 'memory_id'),
      workingVersionId: _requiredString(object, 'working_version_id'),
      basePublishedVersionId: _requiredString(
        object,
        'base_published_version_id',
      ),
      resumed: object['replayed'] == true,
    );
  }

  @override
  Future<MemoryPublicationResult> publishChanges({
    required String memoryId,
    required String versionId,
  }) async {
    final response = await _rpc.call(
      'promote_memory_version',
      <String, Object?>{'p_memory_id': memoryId, 'p_version_id': versionId},
    );
    return _publication(response);
  }

  MemoryPublicationResult _publication(Object? response) {
    final object = _object(response);
    return MemoryPublicationResult(
      memoryId: _requiredString(object, 'memory_id'),
      publishedVersionId: _requiredString(object, 'published_version_id'),
      replayed: object['replayed'] == true,
    );
  }

  Map<Object?, Object?> _object(Object? response) {
    if (response is! Map<Object?, Object?>) {
      throw const FormatException(
        'Memory publication RPC returned invalid data.',
      );
    }
    return response;
  }

  String _requiredString(Map<Object?, Object?> response, String key) {
    final value = response[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('Memory publication RPC omitted $key.');
    }
    return value;
  }
}
