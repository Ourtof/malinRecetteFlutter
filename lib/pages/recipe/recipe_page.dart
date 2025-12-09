import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/config/api_config.dart';
import 'package:malinrecetteflutter/pages/recipe/recipe_detail_page.dart';
import 'package:malinrecetteflutter/pages/recipe/add_recipe_page.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/recipe.dart';
import '../../../services/recipe_service.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final TextEditingController _searchController = TextEditingController();
  late final RecipeService _recipeService;
  bool _isLogged = false;
  String? _selectedTag;

  Future<PaginatedRecipes>? _futureRecipes;

  bool _isRecommending = false;

  @override
  void initState() {
    super.initState();
    _recipeService = RecipeService(baseUrl: ApiConfig.baseUrl);
    _checkAuth();
    _loadRecipes();
  }

  void _loadRecipes({int page = 1}) {
    final query = _searchController.text.trim().isEmpty
        ? null
        : _searchController.text.trim();

    setState(() {
      _futureRecipes = _recipeService.getRecipes(
        query: query,
        tag: _selectedTag,
        page: page,
        limit: 10,
      );
    });
  }

  // Si non authentifié, on ne propose pas l'ajout de recette
  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    setState(() {
      _isLogged = token != null;
    });
  }

  Future<void> _openAddRecipe() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddRecipePage(recipeService: _recipeService),
      ),
    );

    // Si la page d'ajout renvoie "true", on recharge la liste
    if (result == true) {
      _loadRecipes();
    }
  }

  Future<void> _recommendRecipe() async {
    // Empêche le spam : si un appel est déjà en cours, on ne relance pas un deuxième clic.
    if (_isRecommending) return;

    setState(() {
      _isRecommending = true;
    });

    try {
      final recommended = await _recipeService.getRecommendedRecipe();

      // Sécurité Flutter : si le widget a été détruit pendant l’attente (ex : navigation), on arrête tout.
      // Fait en sorte de ne pas avoir d'erreur Flutter si l'utilisateur quitte la page par exemple.
      if (!mounted) return;

      if (recommended == null) {
        // CAS ECHEC : Aucune recette pour ce profil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Aucune recette ne correspond à ton profil. "
              "Modifie ton profil ou ajoute de nouvelles recettes.",
            ),
          ),
        );
        return;
      }

      // CAS SUCCES : On charge la recette complète pour afficher la page de détail
      final recipe = await _recipeService.getRecipe(recommended.id);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
      );
      // catch : gestion des erreurs
    } catch (e) {
      if (!mounted) return;

      final error = e.toString().toLowerCase();
      String userMessage;

      if (error.contains('profil alimentaire non')) {
        userMessage =
            "Ton profil alimentaire n’est pas encore rempli. Va dans la page Profil et remplis-le pour activer la recommandation.";
      } else if (error.contains('utilisateur non connect')) {
        userMessage =
            "Connecte-toi pour utiliser la recommandation de recettes.";
      } else {
        userMessage =
            "Impossible de te proposer une recette pour le moment. Réessaie plus tard.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessage)));
    } finally {
      if (mounted) {
        setState(() {
          _isRecommending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(height: 88),
      bottomNavigationBar: const FooterWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isLogged
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bouton reco en bas à gauche
                    FloatingActionButton.extended(
                      heroTag: 'recommend_fab',
                      onPressed: _isRecommending ? null : _recommendRecipe,
                      label: const Text(
                        "Me proposer une recette",
                      ), //: const Icon(Icons.add),
                    ),
                    FloatingActionButton(
                      heroTag: 'add_fab',
                      onPressed: _openAddRecipe,
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            )
          : null,

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une recette...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadRecipes();
                      },
                    ),
                  ),
                  onSubmitted: (_) => _loadRecipes(),
                ),
              ),

              // 🔽 Bouton reset tags (affiché seulement si un tag est sélectionné)
              if (_selectedTag != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedTag = null;
                        });
                        _loadRecipes();
                      },
                      icon: const Icon(Icons.filter_alt_off, size: 16),
                      label: const Text(
                        'Réinitialiser les filtres',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.06),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.35),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Liste des recettes
              Expanded(
                child: FutureBuilder<PaginatedRecipes>(
                  future: _futureRecipes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erreur : ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final data = snapshot.data;
                    if (data == null || data.items.isEmpty) {
                      return const Center(
                        child: Text('Aucune recette trouvée.'),
                      );
                    }

                    final recipes = data.items;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1;
                        if (constraints.maxWidth >= 1000) {
                          crossAxisCount = 3;
                        } else if (constraints.maxWidth >= 650) {
                          crossAxisCount = 2;
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 4 / 3,
                              ),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RecipeDetailPage(recipe: recipe),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 1.5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Icône + titre
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.fastfood, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              recipe.titre,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Image
                                      if (recipe.illustration != null &&
                                          recipe
                                              .illustration!
                                              .nomFichier
                                              .isNotEmpty)
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              '${ApiConfig.baseUrl}/api/illustrations/${recipe.illustration!.nomFichier}',
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return const SizedBox.shrink();
                                                  },
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox(height: 4),

                                      const SizedBox(height: 8),

                                      // Auteur + date
                                      if (recipe.auteur != null)
                                        Text(
                                          'par ${recipe.auteur!.pseudo}'
                                          '${recipe.dateRecette != null ? " • ${_formatDate(recipe.dateRecette)}" : ""}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),

                                      const SizedBox(height: 4),

                                      // Tags
                                      if (recipe.tags.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 4,
                                          runSpacing: -8,
                                          children: recipe.tags.map((t) {
                                            final isSelected =
                                                t.contenu == _selectedTag;
                                            return ActionChip(
                                              label: Text(
                                                t.contenu,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  // si on reclique sur le même tag, on enlève le filtre
                                                  if (_selectedTag ==
                                                      t.contenu) {
                                                    _selectedTag = null;
                                                  } else {
                                                    _selectedTag = t.contenu;
                                                  }
                                                });
                                                _loadRecipes();
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
