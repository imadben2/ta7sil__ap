import 'package:flutter/widgets.dart';

/// Video fit mode options for Orax Video Player
enum VideoFitMode {
  /// Video fits within bounds with letterboxing (default)
  contain,

  /// Video fills entire container (may be stretched)
  fill,

  /// Video covers entire container (may be cropped)
  cover,

  /// Video fits to container width
  fitWidth,

  /// Video fits to container height
  fitHeight,
}

/// Extension to convert VideoFitMode to Flutter BoxFit
extension VideoFitModeExtension on VideoFitMode {
  /// Convert to Flutter BoxFit
  BoxFit toBoxFit() {
    switch (this) {
      case VideoFitMode.contain:
        return BoxFit.contain;
      case VideoFitMode.fill:
        return BoxFit.fill;
      case VideoFitMode.cover:
        return BoxFit.cover;
      case VideoFitMode.fitWidth:
        return BoxFit.fitWidth;
      case VideoFitMode.fitHeight:
        return BoxFit.fitHeight;
    }
  }

  /// Get display name in Arabic
  String get displayNameAr {
    switch (this) {
      case VideoFitMode.contain:
        return 'احتواء';
      case VideoFitMode.fill:
        return 'ملء';
      case VideoFitMode.cover:
        return 'تغطية';
      case VideoFitMode.fitWidth:
        return 'ملاءمة العرض';
      case VideoFitMode.fitHeight:
        return 'ملاءمة الارتفاع';
    }
  }

  /// Get display name in English
  String get displayNameEn {
    switch (this) {
      case VideoFitMode.contain:
        return 'Contain';
      case VideoFitMode.fill:
        return 'Fill';
      case VideoFitMode.cover:
        return 'Cover';
      case VideoFitMode.fitWidth:
        return 'Fit Width';
      case VideoFitMode.fitHeight:
        return 'Fit Height';
    }
  }
}
