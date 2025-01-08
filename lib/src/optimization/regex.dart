class Regex {
  static final String numeric = '[0-9]+';
  static final String alphanumeric = '[A-Z \$%*+\\-./:]+';
  static String kanji = r'(?:\u3000-\u303F|\u3040-\u309F|\u30A0-\u30FF|' +
      r'\uFF00-\uFFEF|\u4E00-\u9FAF|\u2605-\u2606|\u2190-\u2195|\u203B|' +
      r'\u2010\u2015\u2018\u2019\u2025\u2026\u201C\u201D\u2225\u2260|' +
      r'\u0391-\u0451|\u00A7\u00A8\u00B1\u00B4\u00D7\u00F7)+';

  static final String byte = r'(?:(?![A-Z0-9 \$%*+\\-./:]|' + kanji + r')(?:.|[\r\n]))+';

  static final RegExp KANJI = RegExp(kanji, unicode: true);
  static final RegExp BYTE_KANJI = RegExp('[^A-Z0-9 \$%*+\\-./:]+', unicode: true);
  static final RegExp BYTE = RegExp(byte, unicode: true);
  static final RegExp NUMERIC = RegExp(numeric);
  static final RegExp ALPHANUMERIC = RegExp(alphanumeric);

  static final RegExp TEST_KANJI = RegExp('^' + kanji + r'$', unicode: true);
  static final RegExp TEST_NUMERIC = RegExp('^' + numeric + r'$');
  static final RegExp TEST_ALPHANUMERIC = RegExp('^[A-Z0-9 \$%*+\\-./:]+\$');

  static bool testKanji(String str) {
    return TEST_KANJI.hasMatch(str);
  }

  static bool testNumeric(String str) {
    return TEST_NUMERIC.hasMatch(str);
  }

  static bool testAlphanumeric(String str) {
    return TEST_ALPHANUMERIC.hasMatch(str);
  }
}