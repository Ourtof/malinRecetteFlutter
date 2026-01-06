import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/models/recipe.dart';
import 'package:malinrecetteflutter/ui/widget/recipe/recipe_card.dart';

class RecipeGrid extends StatelessWidget {
  final List<Recipe> recipes;
  final String? selectedTag;
  final Function(String) onTagTap;
  final Function(Recipe) onRecipeTap;

  const RecipeGrid({
    super.key,
    required this.recipes,
    this.selectedTag,
    required this.onTagTap,
    required this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1000) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 650) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 4 / 3,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) => RecipeCard(
            recipe: recipes[index],
            selectedTag: selectedTag,
            onTagTap: onTagTap,
            onCardTap: () => onRecipeTap(recipes[index]),
          ),
        );
      },
    );
  }
}


