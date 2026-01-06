import 'package:malinrecetteflutter/models/recipe_author.dart';
import 'package:malinrecetteflutter/models/recipe_illustration.dart';
import 'package:malinrecetteflutter/models/recipe_tag.dart';

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
      // ⬇️ ICI : on ne caste plus en List directement
      tags: _parseTags(json['tags']),
    );
  }

  /// Accepte `tags` au format:
  /// - liste: [ {...}, {...} ]
  /// - ou map: { "0": {...}, "1": {...} }
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
}
