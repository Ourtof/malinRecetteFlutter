class RecommendedRecipe {
  final int id;
  final String titre;
  final List<String> tags;

  RecommendedRecipe({
    required this.id,
    required this.titre,
    required this.tags,
  });

  factory RecommendedRecipe.fromJson(Map<String, dynamic> json) {
    return RecommendedRecipe(
      id: json['id'] as int,
      titre: json['titre'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
    );
  }
}
