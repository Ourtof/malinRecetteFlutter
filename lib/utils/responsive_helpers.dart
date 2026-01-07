import 'package:flutter/material.dart';

// helpers pour le responsive
class ResponsiveHelpers {
  static const double mobileBreakpoint = 600;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  // retourne une valeur selon si on est sur mobile ou desktop
  static T mobileOrDesktop<T>(
    BuildContext context,
    T mobileValue,
    T desktopValue,
  ) {
    return isMobile(context) ? mobileValue : desktopValue;
  }
}

