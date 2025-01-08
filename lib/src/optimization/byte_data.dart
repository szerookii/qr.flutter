import 'dart:convert';
import 'dart:typed_data';
import 'bit_buffer.dart';
import 'mode.dart';

class ByteData {
  final Mode mode;
  final Uint8List data;

  ByteData(dynamic data)
      : mode = Mode.BYTE,
        data = data is String ? Uint8List.fromList(utf8.encode(data)) : Uint8List.fromList(data);

  static int getBitsLength(int length) {
    return length * 8;
  }

  int getLength() {
    return data.length;
  }

  int getBitsLengthInstance() {
    return ByteData.getBitsLength(data.length);
  }

  void write(BitBuffer bitBuffer) {
    for (int i = 0; i < data.length; i++) {
      bitBuffer.put(data[i], 8);
    }
  }
}