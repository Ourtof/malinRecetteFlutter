import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:malinrecetteflutter/repositories/user_repository.dart';

import '../fake_api_client.dart';

void main() {
  late UserRepository repository;
  late FakeApiClient api;

  setUp(() {
    initApiTests();
    api = FakeApiClient();
  });

  group('UserRepository.getProfile', () {
    test('retourne le profil utilisateur', () async {
      // Given
      api.onRequest = (request) async {
        expect(request.endpoint, '/api/user');
        return jsonResponse({
          'email': 'u@test.fr',
          'pseudo': 'gourmand',
          'prenom': 'Paul',
        });
      };
      repository = UserRepository(apiService: api);

      // When
      final profile = await repository.getProfile();

      // Then
      expect(profile['pseudo'], 'gourmand');
    });

    test('lève une exception en cas d\'erreur', () async {
      // Given
      api.onRequest = (_) async => http.Response('erreur', 500);
      repository = UserRepository(apiService: api);

      // Then
      expect(() => repository.getProfile(), throwsA(isA<Exception>()));
    });
  });

  group('UserRepository.updateProfile', () {
    test('met à jour le profil et retourne les données', () async {
      // Given
      api.onRequest = (request) async {
        expect(request.body?['pseudo'], 'nouveau_pseudo');
        expect(request.body?.containsKey('password'), isFalse);
        return jsonResponse({'pseudo': 'nouveau_pseudo'});
      };
      repository = UserRepository(apiService: api);

      // When
      final result = await repository.updateProfile(
        prenom: 'Paul',
        nom: 'Martin',
        pseudo: '  nouveau_pseudo  ',
        email: 'u@test.fr',
        adresse: '1 rue Test',
        ville: 'Lyon',
        codePostal: '69001',
      );

      // Then
      expect(result['pseudo'], 'nouveau_pseudo');
    });

    test('inclut le mot de passe s\'il est fourni', () async {
      // Given
      Map<String, dynamic>? sentBody;
      api.onRequest = (request) async {
        sentBody = request.body;
        return jsonResponse({'ok': true});
      };
      repository = UserRepository(apiService: api);

      // When
      await repository.updateProfile(
        prenom: 'Paul',
        nom: 'Martin',
        pseudo: 'user',
        email: 'u@test.fr',
        password: 'NewPass1!',
        adresse: '1 rue Test',
        ville: 'Lyon',
        codePostal: '69001',
      );

      // Then
      expect(sentBody?['password'], 'NewPass1!');
    });

    test('lève le message d\'erreur parsé pour un 429', () async {
      // Given
      api.onRequest = (_) async {
        return jsonResponse({'error': 'Trop de requêtes'}, statusCode: 429);
      };
      repository = UserRepository(apiService: api);

      // Then
      expect(
        () => repository.updateProfile(
          prenom: 'Paul',
          nom: 'Martin',
          pseudo: 'user',
          email: 'u@test.fr',
          adresse: '1 rue Test',
          ville: 'Lyon',
          codePostal: '69001',
        ),
        throwsA('Trop de requêtes'),
      );
    });
  });

  group('UserRepository.getFoodProfile', () {
    test('retourne le profil alimentaire', () async {
      // Given
      api.onRequest = (request) async {
        expect(request.endpoint, '/api/me/food-profile');
        return jsonResponse({
          'goalType': 'PERTE_POIDS',
          'dietType': 'VEGETARIEN',
          'isHalal': false,
        });
      };
      repository = UserRepository(apiService: api);

      // When
      final profile = await repository.getFoodProfile();

      // Then
      expect(profile['dietType'], 'VEGETARIEN');
    });
  });

  group('UserRepository.updateFoodProfile', () {
    test('envoie les allergies et le profil alimentaire', () async {
      // Given
      Map<String, dynamic>? sentBody;
      api.onRequest = (request) async {
        sentBody = request.body;
        return jsonResponse({'ok': true});
      };
      repository = UserRepository(apiService: api);

      // When
      await repository.updateFoodProfile(
        goalType: 'MAINTIEN',
        dietType: 'OMNIVORE',
        isHalal: true,
        allergies: {'GLUTEN', 'LAIT'},
        otherAllergies: '  Kiwi  ',
      );

      // Then
      expect(sentBody?['goalType'], 'MAINTIEN');
      expect(sentBody?['allergies'], ['GLUTEN', 'LAIT']);
      expect(sentBody?['autreAllergies'], 'Kiwi');
    });
  });

  group('UserRepository.deleteProfile', () {
    test('supprime le profil sans erreur', () async {
      // Given
      String? calledMethod;
      String? calledEndpoint;
      api.onRequest = (request) async {
        calledMethod = request.method;
        calledEndpoint = request.endpoint;
        return jsonResponse({'ok': true});
      };
      repository = UserRepository(apiService: api);

      // When
      await repository.deleteProfile();

      // Then
      expect(calledMethod, 'DELETE');
      expect(calledEndpoint, '/api/user');
    });
  });
}
