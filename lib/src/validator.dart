/*
 * QR.Flutter
 * Copyright (c) 2019 the QR.Flutter authors.
 * See LICENSE for distribution and usage details.
 */

import 'package:qr/qr.dart';

import 'optimization/mode.dart';
import 'optimization/segments.dart';
import 'qr_versions.dart';

/// A utility class for validating and pre-rendering QR code data.
class QrValidator {
  /// Attempt to parse / generate the QR code data and check for any errors. The
  /// resulting [QrValidationResult] object will hold the status of the QR code
  /// as well as the generated QR code data.
  static QrValidationResult validate({
    required String data,
    int version = QrVersions.auto,
    int errorCorrectionLevel = QrErrorCorrectLevel.L,
  }) {
    late final QrCode qrCode;
    try {
      if (version != QrVersions.auto) {
        qrCode = QrCode(version, errorCorrectionLevel);
        final segments = fromString(data, version);

        debugPrint('Segments size: ${segments.length}');

        for (final segment in segments) {
          switch(segment.mode) {
            case Mode.NUMERIC:
              qrCode.addNumeric(segment.data);
              break;
            case Mode.ALPHANUMERIC:
              qrCode.addAlphaNumeric(segment.data);
              break;
            default:
              qrCode.addData(segment.data);
              break;
          }
        }
      } else {
        qrCode = QrCode.fromData(
          data: data,
          errorCorrectLevel: errorCorrectionLevel,
        );
      }
      return QrValidationResult(
        status: QrValidationStatus.valid,
        qrCode: qrCode,
      );
    } on InputTooLongException catch (title) {
      return QrValidationResult(
        status: QrValidationStatus.contentTooLong,
        error: title,
      );
    } on Exception catch (ex) {
      return QrValidationResult(status: QrValidationStatus.error, error: ex);
    }
  }
}

/// Captures the status or a QR code validation operations, as well as the
/// rendered and validated data / object so that it can be used in any
/// secondary operations (to avoid re-rendering). It also keeps any exception
/// that was thrown.
class QrValidationResult {
  /// Create a new validation result instance.
  QrValidationResult({required this.status, this.qrCode, this.error});

  /// The status of the validation operation.
  QrValidationStatus status;

  /// The rendered QR code data / object.
  QrCode? qrCode;

  /// The exception that was thrown in the event of a non-valid result (if any).
  Exception? error;

  /// The validation result returned a status of valid;
  bool get isValid => status == QrValidationStatus.valid;
}

/// The status of the QR code data you requested to be validated.
enum QrValidationStatus {
  /// The QR code data is valid for the provided parameters.
  valid,

  /// The QR code data is too long for the provided version + error check
  /// configuration or too long to be contained in a QR code.
  contentTooLong,

  /// An unknown / unexpected error occurred when we tried to validate the QR
  /// code data.
  error,
}
