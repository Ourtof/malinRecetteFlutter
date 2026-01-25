import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/models/paginated_admin_recipes.dart';
import 'package:malinrecetteflutter/models/admin_recipe.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_recipe_search_bar.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_recipe_count_bar.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_recipe_table.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_recipe_pagination.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_error_widget.dart';

class AdminRecipeListContent extends StatelessWidget {
  final Future<PaginatedAdminRecipes>? futureRecipes;
  final TextEditingController searchController;
  final int currentPage;
  final Set<int> deletingRecipeIds;
  final Function(String) onSearchSubmitted;
  final VoidCallback onSearchClear;
  final VoidCallback onRefresh;
  final Function(int) onPageChange;
  final Function(AdminRecipe) onDelete;
  final Function(AdminRecipe) onEdit;
  final Function(AdminRecipe) onView;

  const AdminRecipeListContent({
    super.key,
    required this.futureRecipes,
    required this.searchController,
    required this.currentPage,
    required this.deletingRecipeIds,
    required this.onSearchSubmitted,
    required this.onSearchClear,
    required this.onRefresh,
    required this.onPageChange,
    required this.onDelete,
    required this.onEdit,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaginatedAdminRecipes>(
      future: futureRecipes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return AdminErrorWidget(
            error: 'Erreur de chargement : ${snapshot.error}',
            onRetry: onRefresh,
          );
        }

        final paginatedRecipes = snapshot.data;
        if (paginatedRecipes == null || paginatedRecipes.items.isEmpty) {
          return Center(
            child: Text(
              'Aucune recette à afficher.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminRecipeSearchBar(
              controller: searchController,
              onClear: onSearchClear,
              onSubmitted: onSearchSubmitted,
            ),
            const SizedBox(height: 12),
            AdminRecipeCountBar(
              count: paginatedRecipes.total,
              onRefresh: onRefresh,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AdminRecipeTable(
                recipes: paginatedRecipes.items,
                deletingRecipeIds: deletingRecipeIds,
                onDelete: onDelete,
                onEdit: onEdit,
                onView: onView,
              ),
            ),
            AdminRecipePagination(
              data: paginatedRecipes,
              currentPage: currentPage,
              onPageChange: onPageChange,
            ),
          ],
        );
      },
    );
  }
}
