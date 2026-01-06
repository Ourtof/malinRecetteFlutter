import 'package:flutter/material.dart';

// Helpers pour navigation
class NavigationHelpers {
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

