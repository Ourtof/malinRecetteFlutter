import 'package:malinrecetteflutter/api/api_service.dart';
import 'package:malinrecetteflutter/config/api_config.dart';

// Factory pour créer des instances ApiService
// pour éviter de créer plusieurs instances
class ApiServiceFactory {
  static ApiService? _instance;

  // retourne une instance unique d'ApiService (singleton)
  static ApiService create() {
    _instance ??= ApiService(baseUrl: ApiConfig.baseUrl);
    return _instance!;
  }
}


