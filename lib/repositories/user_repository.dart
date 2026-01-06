import 'dart:convert';
import 'package:malinrecetteflutter/api/api_service.dart';

// Repository pour la gestion des utilisateurs
class UserRepository {
  final ApiService _apiService;

  UserRepository({required ApiService apiService}) : _apiService = apiService;

  // Récupère le profil de l'utilisateur connecté
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiService.get(
      '/api/user',
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors du chargement du profil (${response.statusCode}) : ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Met à jour le profil de l'utilisateur
  Future<Map<String, dynamic>> updateProfile({
    required String prenom,
    required String nom,
    required String pseudo,
    required String email,
    String? password,
    required String adresse,
    required String ville,
    required String codePostal,
  }) async {
    final body = <String, dynamic>{
      'prenom': prenom.trim(),
      'nom': nom.trim(),
      'pseudo': pseudo.trim(),
      'email': email.trim(),
      'adresse': adresse.trim(),
      'ville': ville.trim(),
      'codePostal': codePostal.trim(),
    };

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await _apiService.putJson(
      '/api/user',
      body: body,
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la mise à jour du profil (${response.statusCode}) : ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Récupère le profil alimentaire de l'utilisateur
  Future<Map<String, dynamic>> getFoodProfile() async {
    final response = await _apiService.get(
      '/api/me/food-profile',
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors du chargement du profil alimentaire (${response.statusCode}) : ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Met à jour le profil alimentaire de l'utilisateur
  Future<void> updateFoodProfile({
    required String goalType,
    required String dietType,
    required bool isHalal,
    required Set<String> allergies,
    required String otherAllergies,
  }) async {
    final response = await _apiService.putJson(
      '/api/me/food-profile',
      body: {
        'goalType': goalType,
        'dietType': dietType,
        'isHalal': isHalal,
        'allergies': allergies.toList(),
        'autreAllergies': otherAllergies.trim(),
      },
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la mise à jour du profil alimentaire (${response.statusCode}) : ${response.body}',
      );
    }
  }
}

