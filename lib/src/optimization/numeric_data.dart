import 'bit_buffer.dart';
import 'mode.dart';

class NumericData {
  final Mode mode;
  final String data;

  NumericData(String data)
      : mode = Mode.NUMERIC,
        data = data.toString();

  static int getBitsLength(int length) {
    return 10 * (length ~/ 3) + ((length % 3) != 0 ? ((length % 3) * 3 + 1) : 0);
  }

  int getLength() {
    return data.length;
  }

  int getBitsLengthInstance() {
    return NumericData.getBitsLength(data.length);
  }

  void write(BitBuffer bitBuffer) {
    int i;
    String group;
    int value;

    // The input data string is divided into groups of three digits,
    // and each group is converted to its 10-bit binary equivalent.
    for (i = 0; i + 3 <= data.length; i += 3) {
      group = data.substring(i, i + 3);
      value = int.parse(group);

      bitBuffer.put(value, 10);
    }

    // If the number of input digits is not an exact multiple of three,
    // the final one or two digits are converted to 4 or 7 bits respectively.
    int remainingNum = data.length - i;
    if (remainingNum > 0) {
      group = data.substring(i);
      value = int.parse(group);

      bitBuffer.put(value, remainingNum * 3 + 1);
    }
  }
}
