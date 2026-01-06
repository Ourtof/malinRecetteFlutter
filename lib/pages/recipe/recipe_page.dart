import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/api/api_service_factory.dart';
import 'package:malinrecetteflutter/models/paginated_recipes.dart';
import 'package:malinrecetteflutter/pages/recipe/recipe_detail_page.dart';
import 'package:malinrecetteflutter/pages/recipe/add_recipe_page.dart';
import 'package:malinrecetteflutter/repositories/recipe_repository.dart';
import 'package:malinrecetteflutter/ui/widget/recipe/recipe_floating_buttons.dart';
import 'package:malinrecetteflutter/ui/widget/recipe/recipe_list.dart';
import 'package:malinrecetteflutter/ui/widget/recipe/recipe_search_bar.dart';
import 'package:malinrecetteflutter/ui/widget/recipe/recipe_filter_reset.dart';
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
      floatingActionButton: RecipeFloatingButtons(
        isLogged: _isLogged,
        isRecommending: _isRecommending,
        onRecommend: _recommendRecipe,
        onAdd: _openAddRecipe,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              RecipeSearchBar(
                controller: _searchController,
                onClear: _clearSearch,
                onSubmitted: () => _loadRecipes(),
              ),
              if (_selectedTag != null)
                RecipeFilterReset(
                  onReset: _clearFilters,
                ),
              Expanded(
                child: RecipeList(
                  futureRecipes: _futureRecipes,
                  selectedTag: _selectedTag,
                  currentPage: _currentPage,
                  onTagTap: _toggleTag,
                  onPageChange: (page) => _loadRecipes(page: page),
                  onRecipeTap: (recipe, currentPage) async {
                    final deleted = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailPage(recipe: recipe),
                      ),
                    );
                    if (deleted == true) _loadRecipes(page: currentPage);
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