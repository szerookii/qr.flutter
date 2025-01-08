import 'regex.dart';

class Mode {
  final String id;
  final int bit;
  final List<int> ccBits;

  const Mode._(this.id, this.bit, this.ccBits);

  static const Mode NUMERIC = Mode._('Numeric', 1 << 0, [10, 12, 14]);
  static const Mode ALPHANUMERIC = Mode._('Alphanumeric', 1 << 1, [9, 11, 13]);
  static const Mode BYTE = Mode._('Byte', 1 << 2, [8, 16, 16]);
  static const Mode KANJI = Mode._('Kanji', 1 << 3, [8, 10, 12]);
  static const Mode MIXED = Mode._('Mixed', -1, []);

  static List<Mode> get values => [NUMERIC, ALPHANUMERIC, BYTE, KANJI, MIXED];

  static int getCharCountIndicator(Mode mode, int version) {
    if (mode.ccBits.isEmpty) {
      throw ArgumentError('Invalid mode: $mode');
    }

    if (version < 1 || version > 40) {
      throw ArgumentError('Invalid version: $version');
    }

    if (version >= 1 && version < 10) {
      return mode.ccBits[0];
    } else if (version < 27) {
      return mode.ccBits[1];
    }
    return mode.ccBits[2];
  }

  static Mode getBestModeForData(String dataStr) {
    if (Regex.testNumeric(dataStr)) return NUMERIC;
    if (Regex.testAlphanumeric(dataStr)) return ALPHANUMERIC;
    if (Regex.testKanji(dataStr)) return KANJI;
    return BYTE;
  }

  static String modeToString(Mode mode) {
    return mode.id;
  }

  static bool isValid(Mode mode) {
    return mode.ccBits.isNotEmpty;
  }

  static Mode fromString(String string) {
    switch (string.toLowerCase()) {
      case 'numeric':
        return NUMERIC;
      case 'alphanumeric':
        return ALPHANUMERIC;
      case 'byte':
        return BYTE;
      case 'kanji':
        return KANJI;
      default:
        throw ArgumentError('Unknown mode: $string');
    }
  }

  static Mode from(dynamic value, Mode defaultValue) {
    if (value is Mode && isValid(value)) {
      return value;
    }

    try {
      return fromString(value);
    } catch (_) {
      return defaultValue;
    }
  }
}