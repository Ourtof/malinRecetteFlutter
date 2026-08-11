import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:malinrecetteflutter/repositories/auth_repository.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';

import '../fake_api_client.dart';
import '../helpers/api_test_helpers.dart';

void main() {
  late AuthRepository repository;
  late FakeApiClient api;

  setUp(() {
    initApiTests();
    api = FakeApiClient();
  });

  group('AuthRepository.login', () {
    test('stocke le token et les données utilisateur en cas de succès', () async {
      api.onRequest = (request) async {
        expect(request.endpoint, '/api/login');
        return jsonResponse({
          'token': 'jwt-abc',
          'refreshToken': 'refresh-abc',
          'user': {'id': 1, 'email': 'u@test.fr', 'roles': ['ROLE_USER']},
        });
      };

      repository = AuthRepository(apiService: api);
      await repository.login(email: '  u@test.fr  ', password: 'secret');

      expect(await AuthService.getToken(), 'jwt-abc');
      expect(await AuthService.getRefreshToken(), 'refresh-abc');
      expect(await AuthService.isLoggedIn(), isTrue);
    });

    test('lève une erreur avec message 401', () async {
      api.onRequest = (_) async => http.Response('', 401);
      repository = AuthRepository(apiService: api);

      expect(
        () => repository.login(email: 'u@test.fr', password: 'wrong'),
        throwsA('Email ou mot de passe incorrect.'),
      );
    });

    test('formate les erreurs de mot de passe avec détails', () async {
      api.onRequest = (_) async {
        return jsonResponse({
          'error': 'Mot de passe invalide',
          'details': ['Trop court', 'Pas de chiffre'],
        }, statusCode: 400);
      };

      repository = AuthRepository(apiService: api);

      expect(
        () => repository.login(email: 'u@test.fr', password: 'x'),
        throwsA(
          'Mot de passe invalide :\n• Trop court\n• Pas de chiffre',
        ),
      );
    });
  });

  group('AuthRepository.register', () {
    test('connecte automatiquement après inscription', () async {
      api.onRequest = (request) async {
        expect(request.endpoint, '/api/register');
        return jsonResponse({
          'token': 'jwt-new',
          'user': {'id': 2, 'email': 'new@test.fr'},
        }, statusCode: 201);
      };

      repository = AuthRepository(apiService: api);
      await repository.register(
        email: 'new@test.fr',
        password: 'Password1!',
        pseudo: '  chef  ',
        prenom: 'Jean',
        nom: 'Dupont',
        adresse: '1 rue Test',
        ville: 'Paris',
        codePostal: '75001',
      );

      expect(await AuthService.getToken(), 'jwt-new');
      expect(await AuthService.isLoggedIn(), isTrue);
    });
  });

  group('AuthRepository.refreshToken', () {
    test('met à jour le token JWT', () async {
      await AuthService.saveRefreshToken('old-refresh');

      api.onRequest = (request) async {
        expect(request.endpoint, '/api/refresh');
        return jsonResponse({
          'token': 'jwt-refreshed',
          'refreshToken': 'refresh-refreshed',
        });
      };

      repository = AuthRepository(apiService: api);
      await repository.refreshToken();

      expect(await AuthService.getToken(), 'jwt-refreshed');
      expect(await AuthService.getRefreshToken(), 'refresh-refreshed');
    });

    test('lève une exception si aucun refresh token', () async {
      repository = AuthRepository(apiService: api);

      expect(
        () => repository.refreshToken(),
        throwsA(isA<Exception>()),
      );
    });

    test('déconnecte l\'utilisateur si le refresh échoue', () async {
      await AuthService.saveRefreshToken('bad-refresh');
      await AuthService.saveToken('old-jwt');

      api.onRequest = (_) async => http.Response('', 401);
      repository = AuthRepository(apiService: api);

      await expectLater(
        repository.refreshToken(),
        throwsA('Email ou mot de passe incorrect.'),
      );
      expect(await AuthService.isLoggedIn(), isFalse);
    });
  });
}
