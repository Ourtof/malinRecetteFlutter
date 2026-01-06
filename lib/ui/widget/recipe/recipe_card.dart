import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/config/api_config.dart';
import 'package:malinrecetteflutter/models/recipe.dart';
import 'package:malinrecetteflutter/models/recipe_illustration.dart';
import 'package:malinrecetteflutter/utils/date_formatter.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final String? selectedTag;
  final Function(String) onTagTap;
  final VoidCallback onCardTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.selectedTag,
    required this.onTagTap,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onCardTap,
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipeHeader(context),
              const SizedBox(height: 8),
              if (recipe.illustration?.nomFichier.isNotEmpty ?? false)
                _buildRecipeImage(recipe.illustration!),
              const SizedBox(height: 8),
              if (recipe.auteur != null) _buildRecipeAuthor(context),
              const SizedBox(height: 4),
              if (recipe.tags.isNotEmpty) _buildRecipeTags(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.fastfood, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            recipe.titre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeImage(RecipeIllustration illustration) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          '${ApiConfig.baseUrl}/api/illustrations/${illustration.nomFichier}',
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildRecipeAuthor(BuildContext context) {
    return Text(
      'par ${recipe.auteur!.pseudo}'
      '${recipe.dateRecette != null ? " • ${DateFormatter.formatDate(recipe.dateRecette)}" : ""}',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget _buildRecipeTags(BuildContext context) {
    const maxVisibleTags = 3;
    final visibleTags = recipe.tags.take(maxVisibleTags).toList();
    final remainingCount = recipe.tags.length - maxVisibleTags;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ...visibleTags.map((tag) {
            final isSelected = tag.contenu == selectedTag;
            return ActionChip(
              label: Text(
                tag.contenu,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onPressed: () => onTagTap(tag.contenu),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            );
          }),
          if (remainingCount > 0)
            Chip(
              label: Text(
                '+$remainingCount',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
        ],
      ),
    );
  }
}

