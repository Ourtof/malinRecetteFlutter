import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/utils/form_validators.dart';

void main() {
  test('validateEmail retourne une erreur si null ou vide', () {
    // Given
    const String? vide = null;
    const chaineVide = '';

    // When
    final resultVide = validateEmail(vide);
    final resultChaineVide = validateEmail(chaineVide);

    // Then
    expect(resultVide, "L'email est requis");
    expect(resultChaineVide, "L'email est requis");
  });

  test('validateEmail retourne une erreur si format invalide', () {
    // Given
    const sansArobase = 'pas-un-email';
    const domaineIncomplet = 'test@';

    // When
    final resultSansArobase = validateEmail(sansArobase);
    final resultDomaineIncomplet = validateEmail(domaineIncomplet);

    // Then
    expect(resultSansArobase, 'Veuillez entrer une adresse email valide');
    expect(resultDomaineIncomplet, 'Veuillez entrer une adresse email valide');
  });

  test('validateEmail retourne null si email valide', () {
    // Given
    const propre = 'user@example.com';
    const avecEspaces = '  user@example.fr  ';

    // When
    final resultPropre = validateEmail(propre);
    final resultAvecEspaces = validateEmail(avecEspaces);

    // Then
    expect(resultPropre, isNull);
    expect(resultAvecEspaces, isNull);
  });

  test('validateCodePostal retourne une erreur si null ou vide', () {
    // Given
    const String? vide = null;
    const chaineVide = '';

    // When
    final resultVide = validateCodePostal(vide);
    final resultChaineVide = validateCodePostal(chaineVide);

    // Then
    expect(resultVide, 'Le code postal est requis');
    expect(resultChaineVide, 'Le code postal est requis');
  });

  test('validateCodePostal retourne une erreur si non numérique', () {
    // Given
    const avecLettre = '75A01';
    const seulementLettres = 'abc';

    // When
    final resultAvecLettre = validateCodePostal(avecLettre);
    final resultSeulementLettres = validateCodePostal(seulementLettres);

    // Then
    expect(resultAvecLettre, 'Le code postal doit contenir uniquement des chiffres');
    expect(resultSeulementLettres, 'Le code postal doit contenir uniquement des chiffres');
  });

  test('validateCodePostal retourne null si code postal valide', () {
    // Given
    const propre = '75001';
    const avecEspaces = '  13000  ';

    // When
    final resultPropre = validateCodePostal(propre);
    final resultAvecEspaces = validateCodePostal(avecEspaces);

    // Then
    expect(resultPropre, isNull);
    expect(resultAvecEspaces, isNull);
  });
}
