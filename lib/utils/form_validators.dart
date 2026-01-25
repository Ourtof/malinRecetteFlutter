// regex
final emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

// regex code postal
final codePostalRegex = RegExp(r'^[0-9]+$');

// return un message d'erreur si l'email est invalide
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return "L'email est requis";
  }
  
  if (!emailRegex.hasMatch(value.trim())) {
    return "Veuillez entrer une adresse email valide";
  }
  
  return null;
}

// return un message d'erreur si le code postal est invalide aussi
String? validateCodePostal(String? value) {
  if (value == null || value.isEmpty) {
    return "Le code postal est requis";
  }
  
  if (!codePostalRegex.hasMatch(value.trim())) {
    return "Le code postal doit contenir uniquement des chiffres";
  }
  
  return null;
}

