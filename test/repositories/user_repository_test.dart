import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:malinrecetteflutter/repositories/user_repository.dart';

import '../fakes/fake_api_client.dart';
import '../helpers/api_test_helpers.dart';

void main() {
  late UserRepository repository;
  late FakeApiClient api;

  setUp(() {
    initApiTests();
    api = FakeApiClient();
  });

  group('UserRepository.getProfile', () {
    test('retourne le profil utilisateur', () async {
      api.onRequest = (request) async {
        expect(request.endpoint, '/api/user');
        return jsonResponse({
          'email': 'u@test.fr',
          'pseudo': 'gourmand',
          'prenom': 'Paul',
        });
      };

      repository = UserRepository(apiService: api);
      final profile = await repository.getProfile();

      expect(profile['pseudo'], 'gourmand');
    });

    test('lève une exception en cas d\'erreur', () async {
      api.onRequest = (_) async => http.Response('erreur', 500);
      repository = UserRepository(apiService: api);

      expect(() => repository.getProfile(), throwsA(isA<Exception>()));
    });
  });

  group('UserRepository.updateProfile', () {
    test('met à jour le profil et retourne les données', () async {
      api.onRequest = (request) async {
        expect(request.body?['pseudo'], 'nouveau_pseudo');
        expect(request.body?.containsKey('password'), isFalse);
        return jsonResponse({'pseudo': 'nouveau_pseudo'});
      };

      repository = UserRepository(apiService: api);
      final result = await repository.updateProfile(
        prenom: 'Paul',
        nom: 'Martin',
        pseudo: '  nouveau_pseudo  ',
        email: 'u@test.fr',
        adresse: '1 rue Test',
        ville: 'Lyon',
        codePostal: '69001',
      );

      expect(result['pseudo'], 'nouveau_pseudo');
    });

    test('inclut le mot de passe s\'il est fourni', () async {
      api.onRequest = (request) async {
        expect(request.body?['password'], 'NewPass1!');
        return jsonResponse({'ok': true});
      };

      repository = UserRepository(apiService: api);
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
    });

    test('lève le message d\'erreur parsé pour un 429', () async {
      api.onRequest = (_) async {
        return jsonResponse({'error': 'Trop de requêtes'}, statusCode: 429);
      };

      repository = UserRepository(apiService: api);

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
      api.onRequest = (request) async {
        expect(request.endpoint, '/api/me/food-profile');
        return jsonResponse({
          'goalType': 'PERTE_POIDS',
          'dietType': 'VEGETARIEN',
          'isHalal': false,
        });
      };

      repository = UserRepository(apiService: api);
      final profile = await repository.getFoodProfile();

      expect(profile['dietType'], 'VEGETARIEN');
    });
  });

  group('UserRepository.updateFoodProfile', () {
    test('envoie les allergies et le profil alimentaire', () async {
      api.onRequest = (request) async {
        expect(request.body?['goalType'], 'MAINTIEN');
        expect(request.body?['allergies'], ['GLUTEN', 'LAIT']);
        expect(request.body?['autreAllergies'], 'Kiwi');
        return jsonResponse({'ok': true});
      };

      repository = UserRepository(apiService: api);
      await repository.updateFoodProfile(
        goalType: 'MAINTIEN',
        dietType: 'OMNIVORE',
        isHalal: true,
        allergies: {'GLUTEN', 'LAIT'},
        otherAllergies: '  Kiwi  ',
      );
    });
  });

  group('UserRepository.deleteProfile', () {
    test('supprime le profil sans erreur', () async {
      api.onRequest = (request) async {
        expect(request.method, 'DELETE');
        expect(request.endpoint, '/api/user');
        return jsonResponse({'ok': true});
      };

      repository = UserRepository(apiService: api);
      await repository.deleteProfile();
    });
  });
}
