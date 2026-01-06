import 'package:malinrecetteflutter/api/api_service.dart';
import 'package:malinrecetteflutter/config/api_config.dart';

// Factory pour créer des instances ApiService
// Évite la duplication de code dans toutes les pages
class ApiServiceFactory {
  static ApiService create() {
    return ApiService(baseUrl: ApiConfig.baseUrl);
  }
}


