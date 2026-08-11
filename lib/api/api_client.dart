import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Contrat HTTP utilisé par les repositories (testable via un fake).
abstract class ApiClient {
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = false,
  });

  Future<http.Response> postJson(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  });

  Future<http.Response> postBinary(
    String endpoint, {
    required Uint8List bytes,
    required String filename,
    Map<String, String>? additionalHeaders,
    bool requiresAuth = false,
  });

  Future<http.Response> putJson(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  });

  Future<http.Response> patchJson(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  });

  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = false,
  });
}
