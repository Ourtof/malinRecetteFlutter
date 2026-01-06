import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/api/api_service_factory.dart';
import 'package:malinrecetteflutter/models/paginated_recipes.dart';
import 'package:malinrecetteflutter/models/recipe.dart';
import 'package:malinrecetteflutter/pages/recipe/recipe_detail_page.dart';
import 'package:malinrecetteflutter/pages/recipe/add_recipe_page.dart';
import 'package:malinrecetteflutter/repositories/recipe_repository.dart';
import 'package:malinrecetteflutter/ui/widget/recipe/recipe_grid.dart';
import 'package:malinrecetteflutter/ui/widget/recipe/recipe_pagination.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final _searchController = TextEditingController();
  late final RecipeRepository _recipeRepository;
  
  bool _isLogged = false;
  bool _isRecommending = false;
  String? _selectedTag;
  int _currentPage = 1;
  
  Future<PaginatedRecipes>? _futureRecipes;

  @override
  void initState() {
    super.initState();
    _recipeRepository = RecipeRepository(
      apiService: ApiServiceFactory.create(),
    );
    _checkAuth();
    _loadRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final isLogged = await AuthService.isLoggedIn();
    setState(() => _isLogged = isLogged);
  }

  void _loadRecipes({int page = 1}) {
    _currentPage = page;
    final query = _searchController.text.trim();

    setState(() {
      _futureRecipes = _recipeRepository.getRecipes(
        query: query.isEmpty ? null : query,
        tag: _selectedTag,
        page: _currentPage,
        limit: 6,
      );
    });
  }

  Future<void> _openAddRecipe() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddRecipePage(recipeRepository: _recipeRepository)),
    );
    if (result == true) _loadRecipes();
  }

  Future<void> _recommendRecipe() async {
    if (_isRecommending) return;

    setState(() => _isRecommending = true);

    try {
      final recommended = await _recipeRepository.getRecommendedRecipe();
      if (!mounted) return;

      if (recommended == null) {
        _showSnackBar(
          "Aucune recette ne correspond à ton profil. "
          "Modifie ton profil ou ajoute de nouvelles recettes.",
        );
        return;
      }

      final recipe = await _recipeRepository.getRecipe(recommended.id);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(_getErrorMessage(e.toString()));
    } finally {
      if (mounted) setState(() => _isRecommending = false);
    }
  }

  String _getErrorMessage(String error) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('profil alimentaire non')) {
      return "Ton profil alimentaire n'est pas encore rempli. "
          "Va dans la page Profil et remplis-le pour activer la recommandation.";
    }
    if (lowerError.contains('utilisateur non connect')) {
      return "Connecte-toi pour utiliser la recommandation de recettes.";
    }
    return "Impossible de te proposer une recette pour le moment. Réessaie plus tard.";
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearSearch() {
    _searchController.clear();
    _loadRecipes();
  }

  void _toggleTag(String tagContent) {
    setState(() {
      _selectedTag = _selectedTag == tagContent ? null : tagContent;
    });
    _loadRecipes();
  }

  void _clearFilters() {
    setState(() => _selectedTag = null);
    _loadRecipes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(height: 88),
      bottomNavigationBar: const FooterWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingButtons(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              _buildSearchBar(),
              if (_selectedTag != null) _buildFilterReset(),
              Expanded(child: _buildRecipesList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingButtons() {
    if (!_isLogged) return null;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: 'recommend_fab',
              onPressed: _isRecommending ? null : _recommendRecipe,
              label: const Text("Me proposer une recette"),
            ),
            FloatingActionButton(
              heroTag: 'add_fab',
              onPressed: _openAddRecipe,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher une recette...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearSearch,
          ),
        ),
        onSubmitted: (_) => _loadRecipes(),
      ),
    );
  }

  Widget _buildFilterReset() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _clearFilters,
          icon: const Icon(Icons.filter_alt_off, size: 16),
          label: const Text(
            'Réinitialiser les filtres',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            visualDensity: VisualDensity.compact,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.06),
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipesList() {
    return FutureBuilder<PaginatedRecipes>(
      future: _futureRecipes,
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
                selectedTag: _selectedTag,
                onTagTap: _toggleTag,
                onRecipeTap: (recipe) async {
                  final deleted = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailPage(recipe: recipe),
                    ),
                  );
                  if (deleted == true) _loadRecipes(page: _currentPage);
                },
              ),
            ),
            RecipePagination(
              data: data,
              currentPage: _currentPage,
              onPageChange: (page) => _loadRecipes(page: page),
            ),
          ],
        );
      },
    );
  }

}