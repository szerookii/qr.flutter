class BitBuffer {
  List<int> buffer;
  int length;

  BitBuffer()
      : buffer = [],
        length = 0;

  bool get(int index) {
    int bufIndex = index ~/ 8;
    return ((buffer[bufIndex] >> (7 - index % 8)) & 1) == 1;
  }

  void put(int num, int length) {
    for (int i = 0; i < length; i++) {
      putBit(((num >> (length - i - 1)) & 1) == 1);
    }
  }

  int getLengthInBits() {
    return length;
  }

  void putBit(bool bit) {
    int bufIndex = length ~/ 8;
    if (buffer.length <= bufIndex) {
      buffer.add(0);
    }

    if (bit) {
      buffer[bufIndex] |= (0x80 >> (length % 8));
    }

    length++;
  }
}