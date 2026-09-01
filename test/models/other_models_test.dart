import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/models/recommended_recipe.dart';
import 'package:malinrecetteflutter/models/recipe_tag.dart';
import 'package:malinrecetteflutter/models/recipe_author.dart';
import 'package:malinrecetteflutter/models/recipe_illustration.dart';

void main() {
  test('RecommendedRecipe.fromJson parse une recette recommandée', () {
    // Given
    final json = {
      'id': 5,
      'titre': 'Pâtes carbonara',
      'tags': ['ITALIEN', 'RAPIDE'],
    };

    // When
    final recipe = RecommendedRecipe.fromJson(json);

    // Then
    expect(recipe.id, 5);
    expect(recipe.titre, 'Pâtes carbonara');
    expect(recipe.tags, ['ITALIEN', 'RAPIDE']);
  });

  test('RecipeTag.fromJson parse un tag', () {
    // Given
    final json = {'id': 1, 'contenu': 'Vegan'};

    // When
    final tag = RecipeTag.fromJson(json);

    // Then
    expect(tag.id, 1);
    expect(tag.contenu, 'Vegan');
  });

  test('RecipeAuthor.fromJson parse un auteur', () {
    // Given
    final json = {'id': 3, 'pseudo': 'gourmand'};

    // When
    final author = RecipeAuthor.fromJson(json);

    // Then
    expect(author.id, 3);
    expect(author.pseudo, 'gourmand');
  });

  test('RecipeIllustration.fromJson parse une illustration', () {
    // Given
    final json = {
      'id': 9,
      'nomFichier': 'photo.jpg',
    };

    // When
    final illustration = RecipeIllustration.fromJson(json);

    // Then
    expect(illustration.id, 9);
    expect(illustration.nomFichier, 'photo.jpg');
  });
}
