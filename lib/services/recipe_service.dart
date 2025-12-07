import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';

class RecipeService {
  final String baseUrl; //TODO : adapter l'url

  RecipeService({required this.baseUrl});

  Future<PaginatedRecipes> getRecipes({
    String? query,
    String? tag,
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/api/recettes').replace(
      queryParameters: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (tag != null && tag.isNotEmpty) 'tag': tag,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors du chargement des recettes (${response.statusCode})',
      );
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PaginatedRecipes.fromJson(jsonBody);
  }

  Future<Recipe> getRecipe(int id) async {
    final uri = Uri.parse('$baseUrl/api/recettes/$id');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Utilisateur non connecté');
    }

    final uri = Uri.parse('$baseUrl/api/illustrations');

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/octet-stream', // ou 'image/jpeg/png'
        'X-Filename': filename, // à lire côté Symfony
      },
      body: bytes,
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Erreur upload illustration (${response.statusCode}) : ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['id'] as int;
  }

  Future<Recipe> createRecipe({
    required String titre,
    required String contenu,
    required int illustrationId,
    List<String> tags = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Utilisateur non connecté');
    }

    final uri = Uri.parse('$baseUrl/api/recettes');

    final body = jsonEncode({
      'titre': titre,
      'contenu': contenu,
      'tags': tags,
      'illustrationId': illustrationId,
    });

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
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

  Future<List<String>> fetchAvailableTags() async {
    final uri = Uri.parse('$baseUrl/api/tags');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      print('Erreur tags (${response.statusCode}) : ${response.body}');
      throw Exception(
        'Impossible de charger les tags (${response.statusCode})',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => e.toString()).toList();
  }
}
