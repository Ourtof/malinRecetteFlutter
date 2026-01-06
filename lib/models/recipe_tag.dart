class RecipeTag {
  final int id;
  final String contenu;

  RecipeTag({required this.id, required this.contenu});

  factory RecipeTag.fromJson(Map<String, dynamic> json) {
    return RecipeTag(id: json['id'] as int, contenu: json['contenu'] as String);
  }
}

