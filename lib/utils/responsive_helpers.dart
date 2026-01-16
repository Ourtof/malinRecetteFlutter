import 'package:flutter/material.dart';

class ResponsiveHelpers {
  static const double mobileBreakpoint = 600;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  // retourne une valeur mobile ou desktop
  static T mobileOrDesktop<T>(
    BuildContext context,
    T mobileValue,
    T desktopValue,
  ) {
    return isMobile(context) ? mobileValue : desktopValue;
  }
}

