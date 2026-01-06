import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/models/paginated_recipes.dart';
import 'package:malinrecetteflutter/models/recipe.dart';
import 'package:malinrecetteflutter/ui/widget/recipe/recipe_grid.dart';
import 'package:malinrecetteflutter/ui/widget/recipe/recipe_pagination.dart';

class RecipeList extends StatelessWidget {
  final Future<PaginatedRecipes>? futureRecipes;
  final String? selectedTag;
  final int currentPage;
  final Function(String) onTagTap;
  final Function(int) onPageChange;
  final Function(Recipe, int) onRecipeTap;

  const RecipeList({
    super.key,
    required this.futureRecipes,
    this.selectedTag,
    required this.currentPage,
    required this.onTagTap,
    required this.onPageChange,
    required this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaginatedRecipes>(
      future: futureRecipes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        }

        final data = snapshot.data;
        if (data == null || data.items.isEmpty) {
          return const Center(child: Text('Aucune recette trouvée.'));
        }

        return Column(
          children: [
            Expanded(
              child: RecipeGrid(
                recipes: data.items,
                selectedTag: selectedTag,
                onTagTap: onTagTap,
                onRecipeTap: (recipe) => onRecipeTap(recipe, currentPage),
              ),
            ),
            RecipePagination(
              data: data,
              currentPage: currentPage,
              onPageChange: onPageChange,
            ),
          ],
        );
      },
    );
  }
}

