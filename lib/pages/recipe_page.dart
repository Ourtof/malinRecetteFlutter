import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/config/api_config.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final TextEditingController _searchController = TextEditingController();
  late final RecipeService _recipeService;

  Future<PaginatedRecipes>? _futureRecipes;

  @override
  void initState() {
    super.initState();
    /*_recipeService = RecipeService(
      baseUrl: 'http://127.0.0.1:8000',
    );*/ //TODO : à adapter
    _recipeService = RecipeService(baseUrl: ApiConfig.baseUrl);
    _loadRecipes();
  }

  void _loadRecipes({int page = 1}) {
    final query = _searchController.text.trim().isEmpty
        ? null
        : _searchController.text.trim();

    setState(() {
      _futureRecipes = _recipeService.getRecipes(
        query: query,
        page: page,
        limit: 10,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    // Format simple, tu pourras passer plus tard par intl //TODO : à faire
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(height: 88),
      bottomNavigationBar: const FooterWidget(),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 400, vertical: 40),
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

          // Liste
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
                  return const Center(child: Text('Aucune recette trouvée.'));
                }

                final recipes = data.items;

                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.fastfood),
                        title: Text(
                          recipe.titre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (recipe.auteur != null)
                              Text(
                                'par ${recipe.auteur!.pseudo}'
                                '${recipe.dateRecette != null ? " • ${_formatDate(recipe.dateRecette)}" : ""}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (recipe.tags.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: -8,
                                  children: recipe.tags
                                      .map(
                                        (t) => Chip(
                                          label: Text(
                                            t.contenu,
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          // TODO : page de détail
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
