import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/api/api_service.dart';
import 'package:malinrecetteflutter/config/api_config.dart';
import 'package:malinrecetteflutter/repositories/recipe_repository.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/utils/date_formatter.dart';

import '../../models/recipe.dart';
import 'edit_recipe_page.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Recipe _recipe;
  bool _isAdmin = false;
  bool _isDeleting = false;
  late final RecipeRepository _recipeRepository;

  @override
  void initState() {
    super.initState();
    final apiService = ApiService(baseUrl: ApiConfig.baseUrl);
    _recipeRepository = RecipeRepository(apiService: apiService);
    _recipe = widget.recipe;
    _loadAdminStatus();
  }

  Future<void> _loadAdminStatus() async {
    final isAdmin = await AuthService.isAdmin();
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
    });
  }


  Future<void> _deleteRecipe() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la recette ?'),
        content: const Text(
          'Cette opération est définitive. Tu es sûr de vouloir supprimer cette recette ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _recipeRepository.deleteRecipe(_recipe.id);

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Recette supprimée.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString().replaceAll('Exception: ', '')}'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
      });
    }
  }

  Future<void> _editRecipe() async {
    final updated = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(builder: (_) => EditRecipePage(recipe: _recipe)),
    );

    if (!mounted) return;

    if (updated != null) {
      setState(() {
        _recipe = updated;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Recette mise à jour.')));
    }
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
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _recipe.titre,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Actions admin
                if (_isAdmin) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _editRecipe,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Éditer'),
                        ),
                        FilledButton.icon(
                          onPressed: _isDeleting ? null : _deleteRecipe,
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete_outline, size: 18),
                          label: Text(
                            _isDeleting ? 'Suppression...' : 'Supprimer',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

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
                      if (_recipe.auteur != null || _recipe.dateRecette != null)
                        Row(
                          children: [
                            const Icon(Icons.person, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              [
                                if (_recipe.auteur != null)
                                  _recipe.auteur!.pseudo,
                                if (_recipe.dateRecette != null)
                                  DateFormatter.formatDate(_recipe.dateRecette),
                              ].join(' • '),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),

                      if (_recipe.auteur != null || _recipe.dateRecette != null)
                        const SizedBox(height: 12),

                      // Tags
                      if (_recipe.tags.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: -4,
                          children: _recipe.tags
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

                      if (_recipe.tags.isNotEmpty) const SizedBox(height: 16),

                      const Divider(),
                      const SizedBox(height: 16),

                      // Contenu
                      Text(
                        _recipe.contenu,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
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
