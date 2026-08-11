import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
