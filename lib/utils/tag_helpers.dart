class TagHelpers {
  // Extrait le code d'un tag depuis son format raw
  // Format attendu: "{code: GLUTEN, contenu: Contient gluten, categorie: ALLERGENE}"
  static String extractTagCode(String raw) {
    final marker = 'code:';
    final idx = raw.indexOf(marker);
    if (idx == -1) return raw.trim();

    final start = idx + marker.length;
    final comma = raw.indexOf(',', start);
    final end = comma == -1 ? raw.length : comma;

    return raw.substring(start, end).trim();
  }

  // Extrait le label (contenu) d'un tag depuis son format raw
  // Format attendu: "{code: ARACHIDES, contenu: Contient arachides, categorie: ALLERGENE}"
  static String formatTagLabel(String raw) {
    if (!raw.contains('contenu:')) return raw;

    final contenuIndex = raw.indexOf('contenu:');
    if (contenuIndex == -1) return raw;

    final start = contenuIndex + 'contenu:'.length;
    final commaIndex = raw.indexOf(',', start);
    final end = commaIndex == -1 ? raw.length : commaIndex;

    return raw.substring(start, end).trim();
  }

  // Vérifie si un tag est de catégorie OBJECTIF
  static bool isObjectifTag(String raw) =>
      raw.contains('categorie: OBJECTIF') ||
      raw.contains('categorie:OBJECTIF');

  // Vérifie si un tag est de catégorie ALLERGENE
  static bool isAllergeneTag(String raw) =>
      raw.contains('categorie: ALLERGENE') ||
      raw.contains('categorie:ALLERGENE');
}

