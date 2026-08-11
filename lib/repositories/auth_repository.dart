import 'dart:convert';
import 'package:malinrecetteflutter/api/api_client.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';

// Repository pour l'authentification
class AuthRepository {
  final ApiClient _apiService;

  AuthRepository({required ApiClient apiService}) : _apiService = apiService;

  // Connexion d'un utilisateur
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.postJson(
      '/api/login',
      body: {
        'email': email.trim(),
        'password': password,
      },
    );

    if (response.statusCode != 200) {
      throw _parseError(response);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await AuthService.saveToken(data['token'] as String);
    if (data['refreshToken'] != null) {
      await AuthService.saveRefreshToken(data['refreshToken'] as String);
    }
    await AuthService.saveUserData(data['user'] as Map<String, dynamic>);
  }

  // Inscription d'un nouvel utilisateur
  Future<void> register({
    required String email,
    required String password,
    required String pseudo,
    required String prenom,
    required String nom,
    required String adresse,
    required String ville,
    required String codePostal,
  }) async {
    final response = await _apiService.postJson(
      '/api/register',
      body: {
        'email': email.trim(),
        'password': password,
        'pseudo': pseudo.trim(),
        'prenom': prenom.trim(),
        'nom': nom.trim(),
        'adresse': adresse.trim(),
        'ville': ville.trim(),
        'codePostal': codePostal.trim(),
      },
    );

    if (response.statusCode != 201) {
      throw _parseError(response);
    }

    // connexion auto après inscription
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await AuthService.saveToken(data['token'] as String);
    if (data['refreshToken'] != null) {
      await AuthService.saveRefreshToken(data['refreshToken'] as String);
    }
    await AuthService.saveUserData(data['user'] as Map<String, dynamic>);
  }

  // refresh token
  Future<void> refreshToken() async {
    final refreshToken = await AuthService.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('Aucun refresh token disponible');
    }

    final response = await _apiService.postJson(
      '/api/refresh',
      body: {
        'refreshToken': refreshToken,
      },
    );

    if (response.statusCode != 200) {
      // si refresh token est invalide, on déconnecte l'utilisateur
      await AuthService.logout();
      throw _parseError(response);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await AuthService.saveToken(data['token'] as String);
    if (data['refreshToken'] != null) {
      await AuthService.saveRefreshToken(data['refreshToken'] as String);
    }
  }

  // parse les erreurs de réponse
  String _parseError(response) {
    // Gestion spécifique du rate limiting (429)
    if (response.statusCode == 429) {
      try {
        final body = jsonDecode(response.body);
        if (body is Map) {
          if (body['error'] is String) {
            return body['error'] as String;
          }
          if (body['message'] is String) {
            return body['message'] as String;
          }
        }
      } catch (_) {
        // error si échec
      }
      return 'Trop de tentatives. Réessaie plus tard.';
    }

    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        // gestion des erreurs de mot de passe avec détails
        if (body['error'] == 'Mot de passe invalide' && body['details'] is List) {
          final details = (body['details'] as List).cast<String>();
          return 'Mot de passe invalide :\n${details.map((d) => '• $d').join('\n')}';
        }
        
        // message simple - on vérifie 'error' AVANT 'message'
        if (body['error'] is String) {
          return body['error'] as String;
        }
        if (body['message'] is String) {
          return body['message'] as String;
        }
      }
    } catch (_) {
      // corps non-JSON (500), on ignore
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      return "Email ou mot de passe incorrect.";
    }
    if (response.statusCode >= 500) {
      return "Le serveur rencontre un problème. Réessaie plus tard.";
    }
    return "Erreur lors de l'inscription (code ${response.statusCode}).";
  }
}

