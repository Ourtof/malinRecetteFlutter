import 'package:flutter/material.dart';

// Helpers pour les manipulations de couleurs
class ColorHelpers {
  static Color withOpacity(Color color, double opacity) {
    return Color.fromRGBO(
      (color.r * 255.0).round().clamp(0, 255),
      (color.g * 255.0).round().clamp(0, 255),
      (color.b * 255.0).round().clamp(0, 255),
      opacity,
    );
  }
}


