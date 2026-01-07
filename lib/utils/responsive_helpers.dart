import 'package:flutter/material.dart';

/// Helpers pour le responsive design
class ResponsiveHelpers {
  /// Seuil pour considérer un écran comme mobile (en pixels)
  static const double mobileBreakpoint = 600;

  /// Vérifie si l'écran est en mode mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Retourne une valeur selon si on est sur mobile ou desktop
  static T mobileOrDesktop<T>(
    BuildContext context,
    T mobileValue,
    T desktopValue,
  ) {
    return isMobile(context) ? mobileValue : desktopValue;
  }
}

