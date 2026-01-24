import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';

// class pour stocker les requête en attente pendant refresh token
class _PendingRequest {
  final Completer<bool> completer;
  _PendingRequest({required this.completer});
}

// Service API de base pour les appels HTTP
// Gère l'authentification automatique via token JWT et refresh automatique
class ApiService {
  final String baseUrl;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  ApiService({required this.baseUrl});

  // récupère le token JWT depuis SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // rafraîchi le token automatiquement
  Future<bool> _refreshTokenIfNeeded() async {
    // Si déjà en train de rafraîchir, on attend
    if (_isRefreshing) {
      return await _waitForRefresh();
    }

    _isRefreshing = true;

    try {
      final refreshToken = await AuthService.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final uri = Uri.parse('$baseUrl/api/refresh');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await AuthService.saveToken(data['token'] as String);
        if (data['refreshToken'] != null) {
          await AuthService.saveRefreshToken(data['refreshToken'] as String);
        }
        
        // éxécute les requête en attente
        _executePendingRequests();
        return true;
      } else {
        // refresh token invalide => on déconnecte
        await AuthService.logout();
        _rejectPendingRequests();
        return false;
      }
    } catch (e) {
      _rejectPendingRequests();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // attend que le refresh soit terminé
  Future<bool> _waitForRefresh() async {
    final completer = Completer<bool>();
    _pendingRequests.add(_PendingRequest(completer: completer));
    return await completer.future;
  }
  
  void _executePendingRequests() {
    for (final request in _pendingRequests) {
      request.completer.complete(true);
    }
    _pendingRequests.clear();
  }

  void _rejectPendingRequests() {
    for (final request in _pendingRequests) {
      request.completer.complete(false);
    }
    _pendingRequests.clear();
  }

  // gère les erreurs 401 en rafraîchissant automatiquement le token
  Future<http.Response> _handleResponse(
    Future<http.Response> Function() requestFn, {
    required bool requiresAuth,
  }) async {
    var response = await requestFn();

    // si 401 et authentification requise, on essaie de rafraîchir
    if (response.statusCode == 401 && requiresAuth) {
      final refreshed = await _refreshTokenIfNeeded();
      
      if (refreshed) {
        // Réessaie la requête avec le nouveau token
        response = await requestFn();
      }
    }

    return response;
  }

  // construit les headers avec authentification si disponible
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
    return await _handleResponse(
      () async {
        final uri = Uri.parse('$baseUrl$endpoint').replace(
          queryParameters: queryParameters,
        );
        final headers = await _buildHeaders(requiresAuth: requiresAuth);
        return await http.get(uri, headers: headers);
      },
      requiresAuth: requiresAuth,
    );
  }

  // POST request avec JSON
  Future<http.Response> postJson(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    return await _handleResponse(
      () async {
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
      },
      requiresAuth: requiresAuth,
    );
  }

  // POST request pour upload de fichier
  Future<http.Response> postBinary(
    String endpoint, {
    required Uint8List bytes,
    required String filename,
    Map<String, String>? additionalHeaders,
    bool requiresAuth = false,
  }) async {
    return await _handleResponse(
      () async {
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
      },
      requiresAuth: requiresAuth,
    );
  }

  // PUT request avec JSON
  Future<http.Response> putJson(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    return await _handleResponse(
      () async {
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
      },
      requiresAuth: requiresAuth,
    );
  }

  // PATCH request avec JSON
  Future<http.Response> patchJson(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    return await _handleResponse(
      () async {
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
      },
      requiresAuth: requiresAuth,
    );
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    return await _handleResponse(
      () async {
        final uri = Uri.parse('$baseUrl$endpoint');
        final headers = await _buildHeaders(requiresAuth: requiresAuth);
        return await http.delete(uri, headers: headers);
      },
      requiresAuth: requiresAuth,
    );
  }
}

