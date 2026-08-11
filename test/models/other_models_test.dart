import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/models/recommended_recipe.dart';
import 'package:malinrecetteflutter/models/recipe_tag.dart';
import 'package:malinrecetteflutter/models/recipe_author.dart';
import 'package:malinrecetteflutter/models/recipe_illustration.dart';

void main() {
  test('RecommendedRecipe.fromJson parse une recette recommandée', () {
    final recipe = RecommendedRecipe.fromJson({
      'id': 5,
      'titre': 'Pâtes carbonara',
      'tags': ['ITALIEN', 'RAPIDE'],
    });

    expect(recipe.id, 5);
    expect(recipe.titre, 'Pâtes carbonara');
    expect(recipe.tags, ['ITALIEN', 'RAPIDE']);
  });

  test('RecipeTag.fromJson parse un tag', () {
    final tag = RecipeTag.fromJson({'id': 1, 'contenu': 'Vegan'});

    expect(tag.id, 1);
    expect(tag.contenu, 'Vegan');
  });

  test('RecipeAuthor.fromJson parse un auteur', () {
    final author = RecipeAuthor.fromJson({'id': 3, 'pseudo': 'gourmand'});

    expect(author.id, 3);
    expect(author.pseudo, 'gourmand');
  });

  test('RecipeIllustration.fromJson parse une illustration', () {
    final illustration = RecipeIllustration.fromJson({
      'id': 9,
      'nomFichier': 'photo.jpg',
    });

    expect(illustration.id, 9);
    expect(illustration.nomFichier, 'photo.jpg');
  });
}