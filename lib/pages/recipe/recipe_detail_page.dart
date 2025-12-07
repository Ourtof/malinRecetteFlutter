import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const HeaderBar(height: 88),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Titre centré
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    recipe.titre,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Card principale
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                        color: Colors.black.withOpacity(0.06),
                      ),
                    ],
                  ),
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
                                if (recipe.auteur != null)
                                  recipe.auteur!.pseudo,
                                if (recipe.dateRecette != null)
                                  _formatDate(recipe.dateRecette),
                              ].join(' • '),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),

                      if (recipe.auteur != null || recipe.dateRecette != null)
                        const SizedBox(height: 12),

                      // Tags
                      if (recipe.tags.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: -4,
                          children: recipe.tags
                              .map(
                                (t) => Chip(
                                  label: Text(
                                    t.contenu,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        ),

                      if (recipe.tags.isNotEmpty) const SizedBox(height: 16),

                      const Divider(),

                      const SizedBox(height: 16),

                      // Contenu de la recette
                      Text(
                        recipe.contenu,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4, // lisibilité
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FooterWidget(),
    );
  }
}
