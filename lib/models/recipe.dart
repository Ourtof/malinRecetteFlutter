class RecipeTag {
  final int id;
  final String contenu;

  RecipeTag({required this.id, required this.contenu});

  factory RecipeTag.fromJson(Map<String, dynamic> json) {
    return RecipeTag(id: json['id'] as int, contenu: json['contenu'] as String);
  }
}

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

class Recipe {
  final int id;
  final String titre;
  final String contenu;
  final DateTime? dateRecette;
  final RecipeAuthor? auteur;
  final RecipeIllustration? illustration;
  final List<RecipeTag> tags;

  Recipe({
    required this.id,
    required this.titre,
    required this.contenu,
    this.dateRecette,
    this.auteur,
    this.illustration,
    this.tags = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      titre: json['titre'] as String,
      contenu: json['contenu'] as String,
      dateRecette: json['dateRecette'] != null
          ? DateTime.parse(json['dateRecette'] as String)
          : null,
      auteur: json['auteur'] != null
          ? RecipeAuthor.fromJson(json['auteur'] as Map<String, dynamic>)
          : null,
      illustration: json['illustration'] != null
          ? RecipeIllustration.fromJson(
              json['illustration'] as Map<String, dynamic>,
            )
          : null,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((t) => RecipeTag.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PaginatedRecipes {
  final List<Recipe> items;
  final int total;
  final int page;
  final int limit;

  PaginatedRecipes({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaginatedRecipes.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return PaginatedRecipes(
      items: itemsJson
          .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
    );
  }
}
