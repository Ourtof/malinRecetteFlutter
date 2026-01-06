import 'dart:convert';
import 'package:malinrecetteflutter/api/api_service.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';

// Repository pour l'authentification
class AuthRepository {
  final ApiService _apiService;

  AuthRepository({required ApiService apiService}) : _apiService = apiService;

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
      throw Exception(
        'Erreur lors de l\'inscription (${response.statusCode}) : ${response.body}',
      );
    }
  }

  // Parse les erreurs de réponse
  String _parseError(response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] is String) {
        return body['message'] as String;
      }
    } catch (_) {
      // corps non-JSON (HTML 500) → on ignore
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      return "Email ou mot de passe incorrect.";
    }
    if (response.statusCode >= 500) {
      return "Le serveur rencontre un problème. Réessaie plus tard.";
    }
    return "Connexion impossible (code ${response.statusCode}).";
  }
}

