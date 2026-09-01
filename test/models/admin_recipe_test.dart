import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/models/admin_recipe.dart';

void main() {
  final baseJson = {
    'id': 1,
    'titre': 'Curry',
    'contenu': 'Recette épicée',
    'dateRecette': '2024-06-01T12:00:00.000Z',
    'auteur': {'id': 2, 'pseudo': 'chef'},
    'illustration': {'id': 3, 'nomFichier': 'curry.png'},
    'allergies': ['GLUTEN', 'LAIT'],
  };

  test('fromJson parse une recette admin avec tags et allergies', () {
    // Given
    final json = {
      ...baseJson,
      'tags': [
        {'id': 1, 'contenu': 'Plat principal'},
      ],
    };

    // When
    final recipe = AdminRecipe.fromJson(json);

    // Then
    expect(recipe.id, 1);
    expect(recipe.titre, 'Curry');
    expect(recipe.allergies, ['GLUTEN', 'LAIT']);
    expect(recipe.tags, hasLength(1));
  });

  test('fromJson parse les tags au format map', () {
    // Given
    final json = {
      ...baseJson,
      'tags': {
        'a': {'id': 1, 'contenu': 'Épicé'},
      },
    };

    // When
    final recipe = AdminRecipe.fromJson(json);

    // Then
    expect(recipe.tags.first.contenu, 'Épicé');
  });

  test('copyWith remplace uniquement les champs fournis', () {
    // Given
    const original = AdminRecipe(
      id: 1,
      titre: 'Ancien',
      contenu: 'Contenu',
      allergies: ['GLUTEN'],
    );

    // When
    final updated = original.copyWith(titre: 'Nouveau');

    // Then
    expect(updated.titre, 'Nouveau');
    expect(updated.contenu, 'Contenu');
    expect(updated.allergies, ['GLUTEN']);
  });
}
