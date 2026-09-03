import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:malinrecetteflutter/repositories/recipe_repository.dart';
import 'dart:typed_data';

import '../fake_api_client.dart';

void main() {
  late RecipeRepository repository;
  late FakeApiClient api;

  setUp(() {
    initApiTests();
    api = FakeApiClient();
  });

  group('RecipeRepository.getRecipes', () {
    test('retourne une page de recettes', () async {
      // Given
      api.onRequest = (request) async {
        expect(request.endpoint, '/api/recettes');
        expect(request.queryParameters?['page'], '1');
        expect(request.queryParameters?['q'], 'soupe');
        return jsonResponse({
          'items': [
            {'id': 1, 'titre': 'Soupe', 'contenu': 'Chaude'},
          ],
          'total': 1,
          'page': 1,
          'limit': 10,
        });
      };
      repository = RecipeRepository(apiService: api);

      // When
      final result = await repository.getRecipes(query: 'soupe');

      // Then
      expect(result.items, hasLength(1));
      expect(result.items.first.titre, 'Soupe');
    });

    test('lève une exception en cas d\'erreur HTTP', () async {
      // Given
      api.onRequest = (_) async => http.Response('', 500);
      repository = RecipeRepository(apiService: api);

      // Then
      expect(
        () => repository.getRecipes(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('RecipeRepository.getRecipe', () {
    test('retourne une recette par ID', () async {
      // Given
      api.onRequest = (request) async {
        expect(request.endpoint, '/api/recettes/7');
        return jsonResponse({
          'id': 7,
          'titre': 'Risotto',
          'contenu': 'Crémeux',
        });
      };
      repository = RecipeRepository(apiService: api);

      // When
      final recipe = await repository.getRecipe(7);

      // Then
      expect(recipe.titre, 'Risotto');
    });
  });

  group('RecipeRepository.createRecipe', () {
    test('extrait les tagCodes et crée la recette', () async {
      // Given
      api.onRequest = (request) async {
        expect(request.body?['titre'], 'Nouvelle recette');
        expect(request.body?['tagCodes'], ['GLUTEN']);
        return jsonResponse({
          'id': 10,
          'titre': 'Nouvelle recette',
          'contenu': 'Contenu',
        }, statusCode: 201);
      };
      repository = RecipeRepository(apiService: api);

      // When
      final recipe = await repository.createRecipe(
        titre: 'Nouvelle recette',
        contenu: 'Contenu',
        illustrationId: 3,
        tagCodes: ['{code: GLUTEN, contenu: Contient gluten, categorie: ALLERGENE}'],
      );

      // Then
      expect(recipe.id, 10);
    });
  });

  group('RecipeRepository.getRecommendedRecipe', () {
    test('retourne null pour un 204', () async {
      // Given
      api.onRequest = (_) async => http.Response('', 204);
      repository = RecipeRepository(apiService: api);

      // When
      final result = await repository.getRecommendedRecipe();

      // Then
      expect(result, isNull);
    });

    test('retourne une recette recommandée pour un 200', () async {
      // Given
      api.onRequest = (_) async {
        return jsonResponse({
          'id': 5,
          'titre': 'Pâtes',
          'tags': ['RAPIDE'],
        });
      };
      repository = RecipeRepository(apiService: api);

      // When
      final result = await repository.getRecommendedRecipe();

      // Then
      expect(result?.titre, 'Pâtes');
    });
  });

  group('RecipeRepository.uploadIllustration', () {
    test('retourne l\'id de l\'illustration créée', () async {
      // Given
      final bytes = Uint8List.fromList([1, 2, 3]);
      api.onRequest = (request) async {
        expect(request.endpoint, '/api/illustrations');
        expect(request.bytes, bytes);
        return jsonResponse({'id': 99}, statusCode: 201);
      };
      repository = RecipeRepository(apiService: api);

      // When
      final id = await repository.uploadIllustration(bytes, 'img.jpg');

      // Then
      expect(id, 99);
    });
  });

  group('RecipeRepository.deleteRecipe', () {
    test('supprime sans erreur pour un 204', () async {
      // Given
      String? calledEndpoint;
      api.onRequest = (request) async {
        calledEndpoint = request.endpoint;
        return http.Response('', 204);
      };
      repository = RecipeRepository(apiService: api);

      // When
      await repository.deleteRecipe(3);

      // Then
      expect(calledEndpoint, '/api/recettes/3');
    });
  });
}
