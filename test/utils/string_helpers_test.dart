import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/utils/string_helpers.dart';

void main() {
  test('nullIfEmpty retourne null pour null', () {
    expect(StringHelpers.nullIfEmpty(null), isNull);
  });

  test('nullIfEmpty retourne null pour chaîne vide ou espaces', () {
    expect(StringHelpers.nullIfEmpty(''), isNull);
    expect(StringHelpers.nullIfEmpty('   '), isNull);
  });

  test('nullIfEmpty retourne la valeur pour une chaîne non vide', () {
    expect(StringHelpers.nullIfEmpty('recherche'), 'recherche');
    expect(StringHelpers.nullIfEmpty('  tag  '), '  tag  ');
  });
}