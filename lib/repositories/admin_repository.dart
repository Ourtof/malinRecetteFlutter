import 'dart:convert';
import 'package:malinrecetteflutter/api/api_service.dart';
import 'package:malinrecetteflutter/models/admin_user.dart';
import 'package:malinrecetteflutter/models/paginated_users.dart';
import 'package:malinrecetteflutter/models/admin_recipe.dart';
import 'package:malinrecetteflutter/models/paginated_admin_recipes.dart';

class AdminRepository {
  final ApiService _apiService;

  AdminRepository({required ApiService apiService}) : _apiService = apiService;

  // récupère une liste de user
  Future<PaginatedUsers> getUsers({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiService.get(
      '/api/admin/user',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération des utilisateurs '
        '(${response.statusCode}) : ${response.body}',
      );
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PaginatedUsers.fromJson(jsonBody);
  }

  // active ou désactive un user
  Future<AdminUser> toggleUserEnabled(int userId, bool enabled) async {
    final response = await _apiService.patchJson(
      '/api/admin/user/$userId/toggle-enabled',
      body: {'enabled': enabled},
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la mise à jour de l\'utilisateur '
        '(${response.statusCode}) : ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AdminUser.fromJson(data);
  }

  // récupère le profil d'un utilisateur
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final response = await _apiService.get(
      '/api/admin/user/$userId/profile',
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération du profil '
        '(${response.statusCode}) : ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // récupère une liste de recettes
  Future<PaginatedAdminRecipes> getRecipes({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiService.get(
      '/api/admin/recette',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération des recettes '
        '(${response.statusCode}) : ${response.body}',
      );
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PaginatedAdminRecipes.fromJson(jsonBody);
  }

  // récupère une recette par ID
  Future<AdminRecipe> getRecipe(int recipeId) async {
    final response = await _apiService.get(
      '/api/admin/recette/$recipeId',
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération de la recette '
        '(${response.statusCode}) : ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AdminRecipe.fromJson(data);
  }

  // met à jour une recette
  Future<AdminRecipe> updateRecipe(
    int recipeId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.putJson(
      '/api/admin/recette/$recipeId',
      body: data,
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la mise à jour de la recette '
        '(${response.statusCode}) : ${response.body}',
      );
    }

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    return AdminRecipe.fromJson(jsonData);
  }

  // supprime une recette
  Future<void> deleteRecipe(int recipeId) async {
    final response = await _apiService.delete(
      '/api/admin/recette/$recipeId',
      requiresAuth: true,
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Erreur lors de la suppression de la recette '
        '(${response.statusCode}) : ${response.body}',
      );
    }
  }
}

