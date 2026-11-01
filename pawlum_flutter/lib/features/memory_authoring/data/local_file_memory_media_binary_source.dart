import 'dart:io';
import 'dart:typed_data';

import '../domain/repositories/memory_media_binary_source.dart';

class LocalFileMemoryMediaBinarySource implements MemoryMediaBinarySource {
  const LocalFileMemoryMediaBinarySource();

  @override
  Future<Uint8List> read(String localPath) => File(localPath).readAsBytes();
}
