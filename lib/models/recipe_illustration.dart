class RecipeIllustration {
  final int id;
  final String nomFichier;

  RecipeIllustration({required this.id, required this.nomFichier});

  factory RecipeIllustration.fromJson(Map<String, dynamic> json) {
    return RecipeIllustration(
      id: json['id'] as int,
      nomFichier: json['nomFichier'] as String,
    );
  }
}

