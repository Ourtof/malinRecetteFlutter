import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:malinrecetteflutter/api/api_client.dart';

/// Fake HTTP client pour les tests de repositories.
class FakeApiClient implements ApiClient {
  Future<http.Response> Function(FakeApiRequest request)? onRequest;
  final List<FakeApiRequest> requests = [];

  @override
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = false,
  }) {
    return _handle(
      method: 'GET',
      endpoint: endpoint,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  @override
  Future<http.Response> postJson(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) {
    return _handle(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  @override
  Future<http.Response> postBinary(
    String endpoint, {
    required Uint8List bytes,
    required String filename,
    Map<String, String>? additionalHeaders,
    bool requiresAuth = false,
  }) {
    return _handle(
      method: 'POST',
      endpoint: endpoint,
      bytes: bytes,
      filename: filename,
      requiresAuth: requiresAuth,
    );
  }

  @override
  Future<http.Response> putJson(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) {
    return _handle(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  @override
  Future<http.Response> patchJson(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) {
    return _handle(
      method: 'PATCH',
      endpoint: endpoint,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  @override
  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) {
    return _handle(
      method: 'DELETE',
      endpoint: endpoint,
      requiresAuth: requiresAuth,
    );
  }

  Future<http.Response> _handle({
    required String method,
    required String endpoint,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    Uint8List? bytes,
    String? filename,
    bool requiresAuth = false,
  }) async {
    final request = FakeApiRequest(
      method: method,
      endpoint: endpoint,
      queryParameters: queryParameters,
      body: body,
      bytes: bytes,
      filename: filename,
      requiresAuth: requiresAuth,
    );
    requests.add(request);

    if (onRequest == null) {
      return http.Response('No handler configured', 500);
    }
    return onRequest!(request);
  }
}

class FakeApiRequest {
  final String method;
  final String endpoint;
  final Map<String, String>? queryParameters;
  final Map<String, dynamic>? body;
  final Uint8List? bytes;
  final String? filename;
  final bool requiresAuth;

  const FakeApiRequest({
    required this.method,
    required this.endpoint,
    this.queryParameters,
    this.body,
    this.bytes,
    this.filename,
    this.requiresAuth = false,
  });
}
