class RecipeAuthor {
  final int id;
  final String pseudo;

  RecipeAuthor({required this.id, required this.pseudo});

  factory RecipeAuthor.fromJson(Map<String, dynamic> json) {
    return RecipeAuthor(
      id: json['id'] as int,
      pseudo: json['pseudo'] as String,
    );
  }
}

