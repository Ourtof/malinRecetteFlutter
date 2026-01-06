import 'package:malinrecetteflutter/config/api_config.dart';

// Helper pour construire les URLs d'images de manière cohérente
class ImageUrlBuilder {
  // Construit l'URL complète pour une illustration de recette
  static String buildIllustrationUrl(String filename) {
    return '${ApiConfig.baseUrl}/api/illustrations/$filename';
  }
}

