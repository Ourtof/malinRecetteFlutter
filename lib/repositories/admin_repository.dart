import 'dart:convert';
import 'package:malinrecetteflutter/api/api_service.dart';
import 'package:malinrecetteflutter/models/admin_user.dart';

class AdminRepository {
  final ApiService _apiService;

  AdminRepository({required ApiService apiService}) : _apiService = apiService;

  // Récupère la liste des utilisateurs (avec recherche optionnelle)
  Future<List<AdminUser>> getUsers({String? search}) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiService.get(
      '/api/admin/user',
      queryParameters: queryParams.isEmpty ? null : queryParams,
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de la récupération des utilisateurs '
        '(${response.statusCode}) : ${response.body}',
      );
    }

    final dynamic data = jsonDecode(response.body);
    final List<dynamic> rawList = (data is List)
        ? data
        : (data['items'] as List<dynamic>);

    return rawList
        .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Active ou désactive un utilisateur
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
}

