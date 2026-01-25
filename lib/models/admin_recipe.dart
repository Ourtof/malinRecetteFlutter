import 'package:malinrecetteflutter/models/recipe_author.dart';
import 'package:malinrecetteflutter/models/recipe_illustration.dart';
import 'package:malinrecetteflutter/models/recipe_tag.dart';

class AdminRecipe {
  final int id;
  final String titre;
  final String contenu;
  final DateTime? dateRecette;
  final RecipeAuthor? auteur;
  final RecipeIllustration? illustration;
  final List<RecipeTag> tags;
  final List<String> allergies;

  const AdminRecipe({
    required this.id,
    required this.titre,
    required this.contenu,
    this.dateRecette,
    this.auteur,
    this.illustration,
    this.tags = const [],
    this.allergies = const [],
  });

  factory AdminRecipe.fromJson(Map<String, dynamic> json) {
    return AdminRecipe(
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
      tags: _parseTags(json['tags']),
      allergies: (json['allergies'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  static List<RecipeTag> _parseTags(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .map((e) => RecipeTag.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (raw is Map) {
      return raw.values
          .map((e) => RecipeTag.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  AdminRecipe copyWith({
    int? id,
    String? titre,
    String? contenu,
    DateTime? dateRecette,
    RecipeAuthor? auteur,
    RecipeIllustration? illustration,
    List<RecipeTag>? tags,
    List<String>? allergies,
  }) {
    return AdminRecipe(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      dateRecette: dateRecette ?? this.dateRecette,
      auteur: auteur ?? this.auteur,
      illustration: illustration ?? this.illustration,
      tags: tags ?? this.tags,
      allergies: allergies ?? this.allergies,
    );
  }
}
