import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/models/recipe.dart';

void main() {
  final baseJson = {
    'id': 1,
    'titre': 'Tarte aux pommes',
    'contenu': 'Une délicieuse tarte',
    'dateRecette': '2024-03-15T10:00:00.000Z',
    'auteur': {'id': 2, 'pseudo': 'chef_malin'},
    'illustration': {'id': 3, 'nomFichier': 'tarte.jpg'},
  };

  test('fromJson parse une recette complète avec tags en liste', () {
    // Given
    final json = {
      ...baseJson,
      'tags': [
        {'id': 10, 'contenu': 'Dessert'},
      ],
    };

    // When
    final recipe = Recipe.fromJson(json);

    // Then
    expect(recipe.id, 1);
    expect(recipe.titre, 'Tarte aux pommes');
    expect(recipe.contenu, 'Une délicieuse tarte');
    expect(recipe.dateRecette, isNotNull);
    expect(recipe.auteur?.pseudo, 'chef_malin');
    expect(recipe.illustration?.nomFichier, 'tarte.jpg');
    expect(recipe.tags, hasLength(1));
    expect(recipe.tags.first.contenu, 'Dessert');
  });

  test('fromJson parse les tags au format map', () {
    // Given
    final json = {
      ...baseJson,
      'tags': {
        '0': {'id': 10, 'contenu': 'Dessert'},
        '1': {'id': 11, 'contenu': 'Végétarien'},
      },
    };

    // When
    final recipe = Recipe.fromJson(json);

    // Then
    expect(recipe.tags, hasLength(2));
    expect(recipe.tags.map((t) => t.contenu), containsAll(['Dessert', 'Végétarien']));
  });

  test('fromJson retourne une liste vide si tags null ou format inconnu', () {
    // Given
    final jsonTagsNull = {...baseJson, 'tags': null};
    final jsonTagsInvalid = {...baseJson, 'tags': 'invalid'};

    // When
    final recipeTagsNull = Recipe.fromJson(jsonTagsNull);
    final recipeTagsInvalid = Recipe.fromJson(jsonTagsInvalid);

    // Then
    expect(recipeTagsNull.tags, isEmpty);
    expect(recipeTagsInvalid.tags, isEmpty);
  });

  test('fromJson gère les champs optionnels absents', () {
    // Given
    final json = {
      'id': 5,
      'titre': 'Salade',
      'contenu': 'Simple',
    };

    // When
    final recipe = Recipe.fromJson(json);

    // Then
    expect(recipe.dateRecette, isNull);
    expect(recipe.auteur, isNull);
    expect(recipe.illustration, isNull);
    expect(recipe.tags, isEmpty);
  });
}
