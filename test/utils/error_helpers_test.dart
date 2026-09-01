import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/utils/error_helpers.dart';

void main() {
  test('extractErrorMessage retire le préfixe Exception:', () {
    // Given
    final error = Exception('Email invalide');

    // When
    final result = ErrorHelpers.extractErrorMessage(error);

    // Then
    expect(result, 'Email invalide');
  });

  test('extractErrorMessage retourne la chaîne telle quelle sans préfixe', () {
    // Given
    const error = 'Erreur réseau';

    // When
    final result = ErrorHelpers.extractErrorMessage(error);

    // Then
    expect(result, 'Erreur réseau');
  });
}
