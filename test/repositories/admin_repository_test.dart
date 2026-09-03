import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:malinrecetteflutter/repositories/admin_repository.dart';

import '../fake_api_client.dart';
void main() {
  late AdminRepository repository;
  late FakeApiClient api;

  setUp(() {
    initApiTests();
    api = FakeApiClient();
  });

  group('AdminRepository.getUsers', () {
    test('retourne une page d\'utilisateurs', () async {
      // Given
      api.onRequest = (request) async {
        expect(request.endpoint, '/api/admin/user');
        expect(request.queryParameters?['search'], 'admin');
        return jsonResponse({
          'items': [
            {
              'id': 1,
              'email': 'admin@test.fr',
              'pseudo': 'admin',
              'roles': ['ROLE_ADMIN'],
              'enabled': true,
            },
          ],
          'total': 1,
          'page': 1,
          'limit': 20,
        });
      };
      repository = AdminRepository(apiService: api);

      // When
      final result = await repository.getUsers(search: 'admin');

      // Then
      expect(result.items.first.email, 'admin@test.fr');
    });
  });

  group('AdminRepository.toggleUserEnabled', () {
    test('active ou désactive un utilisateur', () async {
      // Given
      api.onRequest = (request) async {
        expect(request.method, 'PATCH');
        expect(request.endpoint, '/api/admin/user/5/toggle-enabled');
        return jsonResponse({
          'id': 5,
          'email': 'u@test.fr',
          'pseudo': 'user',
          'roles': ['ROLE_USER'],
          'enabled': false,
        });
      };
      repository = AdminRepository(apiService: api);

      // When
      final user = await repository.toggleUserEnabled(5, false);

      // Then
      expect(user.enabled, isFalse);
    });
  });

  group('AdminRepository.getUserProfile', () {
    test('retourne le profil d\'un utilisateur', () async {
      // Given
      api.onRequest = (request) async {
        expect(request.endpoint, '/api/admin/user/2/profile');
        return jsonResponse({'prenom': 'Marie', 'nom': 'Martin'});
      };
      repository = AdminRepository(apiService: api);

      // When
      final profile = await repository.getUserProfile(2);

      // Then
      expect(profile['prenom'], 'Marie');
    });
  });

  group('AdminRepository.getRecipes', () {
    test('retourne une page de recettes admin', () async {
      // Given
      api.onRequest = (_) async {
        return jsonResponse({
          'items': [
            {'id': 1, 'titre': 'Curry', 'contenu': 'Épicé'},
          ],
          'total': 1,
          'page': 1,
          'limit': 20,
        });
      };
      repository = AdminRepository(apiService: api);

      // When
      final result = await repository.getRecipes();

      // Then
      expect(result.items.first.titre, 'Curry');
    });
  });

  group('AdminRepository.getRecipe', () {
    test('retourne une recette admin par ID', () async {
      // Given
      api.onRequest = (request) async {
        expect(request.endpoint, '/api/admin/recette/8');
        return jsonResponse({
          'id': 8,
          'titre': 'Tajine',
          'contenu': 'Parfumé',
        });
      };
      repository = AdminRepository(apiService: api);

      // When
      final recipe = await repository.getRecipe(8);

      // Then
      expect(recipe.titre, 'Tajine');
    });
  });

  group('AdminRepository.updateRecipe', () {
    test('met à jour une recette', () async {
      // Given
      api.onRequest = (request) async {
        expect(request.method, 'PUT');
        return jsonResponse({
          'id': 8,
          'titre': 'Tajine modifié',
          'contenu': 'Nouveau contenu',
        });
      };
      repository = AdminRepository(apiService: api);

      // When
      final recipe = await repository.updateRecipe(8, {
        'titre': 'Tajine modifié',
        'contenu': 'Nouveau contenu',
      });

      // Then
      expect(recipe.titre, 'Tajine modifié');
    });
  });

  group('AdminRepository.deleteRecipe', () {
    test('supprime une recette admin', () async {
      // Given
      String? calledEndpoint;
      api.onRequest = (request) async {
        calledEndpoint = request.endpoint;
        return http.Response('', 204);
      };
      repository = AdminRepository(apiService: api);

      // When
      await repository.deleteRecipe(4);

      // Then
      expect(calledEndpoint, '/api/admin/recette/4');
    });
  });
}
