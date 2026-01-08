// Validateurs de formulaire réutilisables

/// Expression régulière pour valider le format d'email
final emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

/// Expression régulière pour valider le code postal (chiffres uniquement)
final codePostalRegex = RegExp(r'^[0-9]+$');

/// Valide une adresse email
/// Retourne un message d'erreur si l'email est invalide, null sinon
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return "L'email est requis";
  }
  
  if (!emailRegex.hasMatch(value.trim())) {
    return "Veuillez entrer une adresse email valide";
  }
  
  return null;
}

/// Valide un code postal
/// Retourne un message d'erreur si le code postal est invalide, null sinon
String? validateCodePostal(String? value) {
  if (value == null || value.isEmpty) {
    return "Le code postal est requis";
  }
  
  if (!codePostalRegex.hasMatch(value.trim())) {
    return "Le code postal doit contenir uniquement des chiffres";
  }
  
  return null;
}

