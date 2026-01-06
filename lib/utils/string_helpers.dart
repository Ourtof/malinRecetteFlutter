// Helpers pour les manipulations de strings
class StringHelpers {
  // Utile pour les paramètres optionnels d'API
  static String? nullIfEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }
}


