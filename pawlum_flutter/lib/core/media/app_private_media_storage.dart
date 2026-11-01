import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

typedef PrivateMediaRootProvider = Future<Directory> Function();

class StoredPrivateMedia {
  const StoredPrivateMedia({
    required this.accountId,
    required this.mediaId,
    required this.filePath,
  });

  final String accountId;
  final String mediaId;
  final String filePath;
}

class AppPrivateMediaStorage {
  AppPrivateMediaStorage({PrivateMediaRootProvider? rootDirectoryProvider})
    : _rootDirectoryProvider =
          rootDirectoryProvider ?? getApplicationSupportDirectory;

  final PrivateMediaRootProvider _rootDirectoryProvider;

  Future<StoredPrivateMedia> importFile({
    required String accountId,
    required String mediaId,
    required File source,
  }) async {
    if (!await source.exists()) {
      throw FileSystemException('Selected media file does not exist.');
    }

    final accountDirectory = await directoryForAccount(accountId);
    await accountDirectory.create(recursive: true);
    final extension = path.extension(source.path).toLowerCase();
    final safeMediaName = _safePathSegment(mediaId);
    final destination = File(
      path.join(accountDirectory.path, '$safeMediaName$extension'),
    );
    final temporary = File('${destination.path}.importing');

    try {
      if (await temporary.exists()) {
        await temporary.delete();
      }
      await source.copy(temporary.path);
      if (await destination.exists()) {
        await destination.delete();
      }
      await temporary.rename(destination.path);
    } finally {
      if (await temporary.exists()) {
        await temporary.delete();
      }
    }

    return StoredPrivateMedia(
      accountId: accountId,
      mediaId: mediaId,
      filePath: destination.path,
    );
  }

  Future<Directory> directoryForAccount(String accountId) async {
    final root = await _rootDirectoryProvider();
    final normalizedRoot = path.normalize(path.absolute(root.path));
    final directory = Directory(
      path.join(
        normalizedRoot,
        'pawlum_private_media',
        _safePathSegment(accountId),
      ),
    );
    final normalizedDirectory = path.normalize(path.absolute(directory.path));
    if (!path.isWithin(normalizedRoot, normalizedDirectory)) {
      throw StateError('Private media path escaped the application scope.');
    }
    return Directory(normalizedDirectory);
  }

  Future<void> deleteAccountMedia(String accountId) async {
    final directory = await directoryForAccount(accountId);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  String _safePathSegment(String value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'must not be empty');
    }
    return base64Url.encode(utf8.encode(value)).replaceAll('=', '');
  }
}
