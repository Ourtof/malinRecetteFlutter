import 'package:malinrecetteflutter/models/admin_recipe.dart';

class PaginatedAdminRecipes {
  final List<AdminRecipe> items;
  final int total;
  final int page;
  final int limit;

  PaginatedAdminRecipes({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaginatedAdminRecipes.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return PaginatedAdminRecipes(
      items: itemsJson
          .map((e) => AdminRecipe.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
    );
  }
}
