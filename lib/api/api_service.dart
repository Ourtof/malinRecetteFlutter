import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Service API de base pour les appels HTTP
// Gère l'authentification automatique via token JWT
class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Récupère le token JWT depuis SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Construit les headers avec authentification si disponible
  Future<Map<String, String>> _buildHeaders({
    Map<String, String>? additionalHeaders,
    bool requiresAuth = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      ...?additionalHeaders,
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters,
    );

    final headers = await _buildHeaders(requiresAuth: requiresAuth);

    return await http.get(uri, headers: headers);
  }

  // POST request avec JSON
  Future<http.Response> postJson(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
      requiresAuth: requiresAuth,
    );

    return await http.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // POST request avec données binaires (pour upload de fichiers)
  Future<http.Response> postBinary(
    String endpoint, {
    required Uint8List bytes,
    required String filename,
    Map<String, String>? additionalHeaders,
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(
      additionalHeaders: {
        'Content-Type': 'application/octet-stream',
        'X-Filename': filename,
        ...?additionalHeaders,
      },
      requiresAuth: requiresAuth,
    );

    return await http.post(uri, headers: headers, body: bytes);
  }

  // PUT request avec JSON
  Future<http.Response> putJson(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
      requiresAuth: requiresAuth,
    );

    return await http.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // PATCH request avec JSON
  Future<http.Response> patchJson(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
      requiresAuth: requiresAuth,
    );

    return await http.patch(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(requiresAuth: requiresAuth);

    return await http.delete(uri, headers: headers);
  }
}

