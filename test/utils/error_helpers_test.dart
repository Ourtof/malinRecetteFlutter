import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/utils/error_helpers.dart';

void main() {
  test('extractErrorMessage retire le préfixe Exception:', () {
    expect(
      ErrorHelpers.extractErrorMessage(Exception('Email invalide')),
      'Email invalide',
    );
  });

  test('extractErrorMessage retourne la chaîne telle quelle sans préfixe', () {
    expect(
      ErrorHelpers.extractErrorMessage('Erreur réseau'),
      'Erreur réseau',
    );
  });
}