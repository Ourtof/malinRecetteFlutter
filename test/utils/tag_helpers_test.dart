import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/utils/tag_helpers.dart';

void main() {
  const rawTag =
      '{code: GLUTEN, contenu: Contient gluten, categorie: ALLERGENE}';

  group('TagHelpers.extractTagCode', () {
    test('extrait le code depuis le format raw', () {
      expect(TagHelpers.extractTagCode(rawTag), 'GLUTEN');
    });

    test('retourne la chaîne brute si pas de marqueur code:', () {
      expect(TagHelpers.extractTagCode('SIMPLE_TAG'), 'SIMPLE_TAG');
    });
  });

  group('TagHelpers.formatTagLabel', () {
    test('extrait le contenu depuis le format raw', () {
      expect(TagHelpers.formatTagLabel(rawTag), 'Contient gluten');
    });

    test('retourne la chaîne brute si pas de contenu:', () {
      expect(TagHelpers.formatTagLabel('SIMPLE_TAG'), 'SIMPLE_TAG');
    });
  });

  group('TagHelpers.isObjectifTag', () {
    test('détecte un tag OBJECTIF avec ou sans espace', () {
      expect(
        TagHelpers.isObjectifTag('{code: X, categorie: OBJECTIF}'),
        isTrue,
      );
      expect(
        TagHelpers.isObjectifTag('{code: X, categorie:OBJECTIF}'),
        isTrue,
      );
      expect(TagHelpers.isObjectifTag(rawTag), isFalse);
    });
  });

  group('TagHelpers.isAllergeneTag', () {
    test('détecte un tag ALLERGENE avec ou sans espace', () {
      expect(TagHelpers.isAllergeneTag(rawTag), isTrue);
      expect(
        TagHelpers.isAllergeneTag('{code: X, categorie:ALLERGENE}'),
        isTrue,
      );
      expect(
        TagHelpers.isAllergeneTag('{code: X, categorie: OBJECTIF}'),
        isFalse,
      );
    });
  });
}
