import 'dart:convert';
import 'package:malinrecetteflutter/api/api_service.dart';
import 'package:malinrecetteflutter/models/admin_user.dart';
import 'package:malinrecetteflutter/models/paginated_users.dart';

class AdminRepository {
  final ApiService _apiService;

  AdminRepository({required ApiService apiService}) : _apiService = apiService;

  // Récupère une liste paginée d'utilisateurs
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

