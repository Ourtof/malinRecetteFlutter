import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000' // Flutter Web
      : 'http://10.0.2.2:8000'; // Si évolution émulateur Android
}
