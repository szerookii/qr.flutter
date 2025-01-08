typedef ToSJISFunction = int Function(String);

class Utils {
  static ToSJISFunction? toSJISFunction;

  static const List<int> CODEWORDS_COUNT = [
    0, 26, 44, 70, 100, 134, 172, 196, 242, 292, 346,
    404, 466, 532, 581, 655, 733, 815, 901, 991, 1085,
    1156, 1258, 1364, 1474, 1588, 1706, 1828, 1921, 2051, 2185,
    2323, 2465, 2611, 2761, 2876, 3034, 3196, 3362, 3532, 3706
  ];

  static int getSymbolSize(int version) {
    if (version < 1 || version > 40) {
      throw ArgumentError('"version" should be in range from 1 to 40');
    }
    return version * 4 + 17;
  }

  static int getSymbolTotalCodewords(int version) {
    return CODEWORDS_COUNT[version];
  }

  static int getBCHDigit(int data) {
    int digit = 0;

    while (data != 0) {
      digit++;
      data >>= 1;
    }

    return digit;
  }

  static void setToSJISFunction(ToSJISFunction f) {
    toSJISFunction = f;
  }

  static bool isKanjiModeEnabled() {
    return toSJISFunction != null;
  }

  static int toSJIS(String kanji) {
    if (toSJISFunction == null) {
      throw StateError('toSJISFunction is not set.');
    }
    return toSJISFunction!(kanji);
  }
}