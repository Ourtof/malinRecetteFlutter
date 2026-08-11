import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/utils/form_validators.dart';

void main() {
  test('validateEmail retourne une erreur si null', () {
    expect(validateEmail(null), "L'email est requis");
  });

  test('validateEmail retourne une erreur si vide', () {
    expect(validateEmail(''), "L'email est requis");
  });

  test('validateEmail retourne une erreur si format invalide', () {
    expect(validateEmail('pas-un-email'), 'Veuillez entrer une adresse email valide');
    expect(validateEmail('test@'), 'Veuillez entrer une adresse email valide');
  });

  test('validateEmail retourne null si email valide', () {
    expect(validateEmail('user@example.com'), isNull);
    expect(validateEmail('  user@example.fr  '), isNull);
  });

  test('validateCodePostal retourne une erreur si null', () {
    expect(validateCodePostal(null), 'Le code postal est requis');
  });

  test('validateCodePostal retourne une erreur si vide', () {
    expect(validateCodePostal(''), 'Le code postal est requis');
  });

  test('validateCodePostal retourne une erreur si non numérique', () {
    expect(validateCodePostal('75A01'), 'Le code postal doit contenir uniquement des chiffres');
    expect(validateCodePostal('abc'), 'Le code postal doit contenir uniquement des chiffres');
  });

  test('validateCodePostal retourne null si code postal valide', () {
    expect(validateCodePostal('75001'), isNull);
    expect(validateCodePostal('  13000  '), isNull);
  });
}