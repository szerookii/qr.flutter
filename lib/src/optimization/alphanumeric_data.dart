import 'mode.dart';
import 'bit_buffer.dart';

class AlphanumericData {
  static List<String> ALPHA_NUM_CHARS = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    ' ', '\$', '%', '*', '+', '-', '.', '/', ':'
  ];

  final Mode mode;
  final String data;

  AlphanumericData(this.data) : mode = Mode.ALPHANUMERIC;

  static int getBitsLength(int length) {
    return 11 * (length ~/ 2) + 6 * (length % 2);
  }

  int getLength() {
    return data.length;
  }

  int getBitsLengthInstance() {
    return AlphanumericData.getBitsLength(data.length);
  }

  void write(BitBuffer bitBuffer) {
    int i;

    for (i = 0; i + 2 <= data.length; i += 2) {
      int value = ALPHA_NUM_CHARS.indexOf(data[i]) * 45;
      value += ALPHA_NUM_CHARS.indexOf(data[i + 1]);
      bitBuffer.put(value, 11);
    }

    if (data.length % 2 != 0) {
      bitBuffer.put(ALPHA_NUM_CHARS.indexOf(data[i]), 6);
    }
  }
}