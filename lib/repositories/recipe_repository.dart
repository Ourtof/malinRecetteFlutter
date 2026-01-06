import 'dart:convert';
import 'dart:typed_data';
import 'package:malinrecetteflutter/api/api_service.dart';
import 'package:malinrecetteflutter/models/paginated_recipes.dart';
import 'package:malinrecetteflutter/models/recipe.dart';
import 'package:malinrecetteflutter/models/recommended_recipe.dart';

// Repository pour la gestion des recettes
// Sépare la logique métier des appels HTTP
class RecipeRepository {
  final ApiService _apiService;

  RecipeRepository({required ApiService apiService})
      : _apiService = apiService;

  // Récupère une liste paginée de recettes
  Future<PaginatedRecipes> getRecipes({
    String? query,
    String? tag,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }
    if (tag != null && tag.isNotEmpty) {
      queryParams['tag'] = tag;
    }

    final response = await _apiService.get(
      '/api/recettes',
      queryParameters: queryParams,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors du chargement des recettes (${response.statusCode})',
      );
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PaginatedRecipes.fromJson(jsonBody);
  }

  // Récupère une recette par son ID
  Future<Recipe> getRecipe(int id) async {
    final response = await _apiService.get('/api/recettes/$id');

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors du chargement de la recette (${response.statusCode})',
      );
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Recipe.fromJson(jsonBody);
  }

  // Upload d'une illustration, retourne l'id créé en BDD
  Future<int> uploadIllustration(Uint8List bytes, String filename) async {
    final response = await _apiService.postBinary(
      '/api/illustrations',
      bytes: bytes,
      filename: filename,
      requiresAuth: true,
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Erreur upload illustration (${response.statusCode}) : ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['id'] as int;
  }

  // Crée une nouvelle recette
  Future<Recipe> createRecipe({
    required String titre,
    required String contenu,
    required int illustrationId,
    List<String> tagCodes = const [],
  }) async {
    // On extrait les codes à partir des strings du style
    // "{code: GLUTEN, contenu: Contient gluten, categorie: ALLERGENE}"
    final extractedCodes = tagCodes
        .map((t) {
          final reg = RegExp(r'code:\s*([A-Z_]+)');
          final match = reg.firstMatch(t);
          return match?.group(1);
        })
        .whereType<String>()
        .toList();

    final body = {
      'titre': titre,
      'contenu': contenu,
      'tags': tagCodes,
      'tagCodes': extractedCodes, // ce que le back attend réellement
      'illustrationId': illustrationId,
    };

    final response = await _apiService.postJson(
      '/api/recettes',
      body: body,
      requiresAuth: true,
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Erreur lors de la création de la recette '
        '(${response.statusCode}) : ${response.body}',
      );
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Recipe.fromJson(jsonBody);
  }

  // Met à jour une recette existante
  Future<Recipe> updateRecipe({
    required int id,
    required String titre,
    required String contenu,
    List<String> tagCodes = const [],
  }) async {
    // On extrait les codes à partir des strings du style
    final extractedCodes = tagCodes
        .map((t) {
          final reg = RegExp(r'code:\s*([A-Z_]+)');
          final match = reg.firstMatch(t);
          return match?.group(1);
        })
        .whereType<String>()
        .toList();

    final body = {
      'titre': titre,
      'contenu': contenu,
      'tagCodes': extractedCodes,
    };

    final response = await _apiService.putJson(
      '/api/recettes/$id',
      body: body,
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la mise à jour de la recette '
        '(${response.statusCode}) : ${response.body}',
      );
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Recipe.fromJson(jsonBody);
  }

  // Récupère la liste des tags disponibles
  Future<List<String>> fetchAvailableTags() async {
    final response = await _apiService.get('/api/tags');

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les tags (${response.statusCode})',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => e.toString()).toList();
  }

  // Récupère une recette recommandée pour l'utilisateur connecté
  Future<RecommendedRecipe?> getRecommendedRecipe() async {
    final response = await _apiService.get(
      '/api/recettes/recommandation',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody =
          jsonDecode(response.body) as Map<String, dynamic>;
      return RecommendedRecipe.fromJson(jsonBody);
    }

    if (response.statusCode == 204) {
      // Aucune recette correspondant au profil
      return null;
    }

    throw Exception(
      'Erreur lors de la recommandation (${response.statusCode}) : ${response.body}',
    );
  }

  // Supprime une recette
  Future<void> deleteRecipe(int id) async {
    final response = await _apiService.delete(
      '/api/recettes/$id',
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

