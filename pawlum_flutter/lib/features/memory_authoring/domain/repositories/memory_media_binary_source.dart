import 'dart:typed_data';

abstract interface class MemoryMediaBinarySource {
  Future<Uint8List> read(String localPath);
}
