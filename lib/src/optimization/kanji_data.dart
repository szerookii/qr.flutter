import 'mode.dart';
import 'utils.dart';
import 'bit_buffer.dart';

class KanjiData {
  final Mode mode;
  final String data;

  KanjiData(this.data) : mode = Mode.KANJI;

  static int getBitsLength(int length) {
    return length * 13;
  }

  int getLength() {
    return data.length;
  }

  int getBitsLengthInstance() {
    return KanjiData.getBitsLength(data.length);
  }

  void write(BitBuffer bitBuffer) {
    for (int i = 0; i < data.length; i++) {
      int value = Utils.toSJIS(data[i]);

      // For characters with Shift JIS values from 0x8140 to 0x9FFC:
      if (value >= 0x8140 && value <= 0x9FFC) {
        // Subtract 0x8140 from Shift JIS value
        value -= 0x8140;
      } 
      // For characters with Shift JIS values from 0xE040 to 0xEBBF
      else if (value >= 0xE040 && value <= 0xEBBF) {
        // Subtract 0xC140 from Shift JIS value
        value -= 0xC140;
      } else {
        throw ArgumentError(
          'Invalid SJIS character: ${data[i]}\nMake sure your charset is UTF-8');
      }

      // Multiply most significant byte of result by 0xC0
      // and add least significant byte to product
      value = (((value >> 8) & 0xff) * 0xC0) + (value & 0xff);

      // Convert result to a 13-bit binary string
      bitBuffer.put(value, 13);
    }
  }
}