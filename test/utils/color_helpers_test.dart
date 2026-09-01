import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/utils/color_helpers.dart';

void main() {
  group('ColorHelpers.withOpacity', () {
    test('applique l\'opacité sur une couleur', () {
      // Given
      const color = Color(0xFFFF0000);

      // When
      final result = ColorHelpers.withOpacity(color, 0.5);

      // Then
      expect(result.r, closeTo(1.0, 0.01));
      expect(result.g, closeTo(0.0, 0.01));
      expect(result.b, closeTo(0.0, 0.01));
      expect(result.a, closeTo(0.5, 0.01));
    });
  });
}
