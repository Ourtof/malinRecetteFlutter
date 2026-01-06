// Helper pour extraire les messages d'erreur de manière cohérente
class ErrorHelpers {
  // Extrait un message d'erreur depuis une exception
  static String extractErrorMessage(dynamic error) {
    final errorString = error.toString();
    // Enlève le préfixe "Exception: "
    return errorString.replaceAll('Exception: ', '');
  }
}


