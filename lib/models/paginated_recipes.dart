import 'package:malinrecetteflutter/models/recipe.dart';

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

