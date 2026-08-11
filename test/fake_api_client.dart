import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:malinrecetteflutter/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake HTTP client pour les tests de repositories.
class FakeApiClient implements ApiClient {
  Future<http.Response> Function(FakeApiRequest request)? onRequest;

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
    );
  }

  Future<http.Response> _handle({
    required String method,
    required String endpoint,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    Uint8List? bytes,
  }) async {
    final request = FakeApiRequest(
      method: method,
      endpoint: endpoint,
      queryParameters: queryParameters,
      body: body,
      bytes: bytes,
    );

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

  const FakeApiRequest({
    required this.method,
    required this.endpoint,
    this.queryParameters,
    this.body,
    this.bytes,
  });
}

void initApiTests() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
}

http.Response jsonResponse(
  Object body, {
  int statusCode = 200,
  Map<String, String>? headers,
}) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: {
      'content-type': 'application/json',
      ...?headers,
    },
  );
}