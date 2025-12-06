import 'package:flutter/material.dart';
import '../../models/recipe.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.titre, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auteur + date
            if (recipe.auteur != null || recipe.dateRecette != null)
              Row(
                children: [
                  const Icon(Icons.person, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    [
                      if (recipe.auteur != null) recipe.auteur!.pseudo,
                      if (recipe.dateRecette != null)
                        _formatDate(recipe.dateRecette),
                    ].join(' • '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // Tags
            if (recipe.tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: -8,
                children: recipe.tags
                    .map(
                      (t) => Chip(
                        label: Text(
                          t.contenu,
                          style: const TextStyle(fontSize: 12),
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),

            const SizedBox(height: 16),

            // TODO plus tard : illustration (image)
            // if (recipe.illustration != null) ...,

            // Contenu de la recette
            Text(recipe.contenu, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
