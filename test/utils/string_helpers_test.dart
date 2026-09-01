import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/utils/string_helpers.dart';

void main() {
  test('nullIfEmpty retourne null pour null', () {
    // Given
    const String? value = null;

    // When
    final result = StringHelpers.nullIfEmpty(value);

    // Then
    expect(result, isNull);
  });

  test('nullIfEmpty retourne null pour chaîne vide ou espaces', () {
    // Given
    const vide = '';
    const espaces = '   ';

    // When
    final resultVide = StringHelpers.nullIfEmpty(vide);
    final resultEspaces = StringHelpers.nullIfEmpty(espaces);

    // Then
    expect(resultVide, isNull);
    expect(resultEspaces, isNull);
  });

  test('nullIfEmpty retourne la valeur pour une chaîne non vide', () {
    // Given
    const recherche = 'recherche';
    const tag = '  tag  ';

    // When
    final resultRecherche = StringHelpers.nullIfEmpty(recherche);
    final resultTag = StringHelpers.nullIfEmpty(tag);

    // Then
    expect(resultRecherche, 'recherche');
    expect(resultTag, '  tag  ');
  });
}
