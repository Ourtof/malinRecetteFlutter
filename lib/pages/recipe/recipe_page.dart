import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/api/api_service_factory.dart';
import 'package:malinrecetteflutter/config/api_config.dart';
import 'package:malinrecetteflutter/models/paginated_recipes.dart';
import 'package:malinrecetteflutter/models/recipe.dart';
import 'package:malinrecetteflutter/models/recipe_illustration.dart';
import 'package:malinrecetteflutter/models/recipe_tag.dart';
import 'package:malinrecetteflutter/pages/recipe/recipe_detail_page.dart';
import 'package:malinrecetteflutter/pages/recipe/add_recipe_page.dart';
import 'package:malinrecetteflutter/repositories/recipe_repository.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/utils/date_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    setState(() => _isLogged = token != null);
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
            Expanded(child: _buildRecipesGrid(data.items)),
            _buildPagination(data),
          ],
        );
      },
    );
  }

  Widget _buildRecipesGrid(List<Recipe> recipes) {
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
          itemBuilder: (context, index) => _buildRecipeCard(recipes[index]),
        );
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final deleted = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
        );
        if (deleted == true) _loadRecipes(page: _currentPage);
      },
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipeHeader(recipe),
              const SizedBox(height: 8),
              if (recipe.illustration?.nomFichier.isNotEmpty ?? false)
                _buildRecipeImage(recipe.illustration!),
              const SizedBox(height: 8),
              if (recipe.auteur != null) _buildRecipeAuthor(recipe),
              const SizedBox(height: 4),
              if (recipe.tags.isNotEmpty) _buildRecipeTags(recipe.tags),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeHeader(Recipe recipe) {
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

  Widget _buildRecipeAuthor(Recipe recipe) {
    return Text(
      'par ${recipe.auteur!.pseudo}'
      '${recipe.dateRecette != null ? " • ${DateFormatter.formatDate(recipe.dateRecette)}" : ""}',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget _buildRecipeTags(List<RecipeTag> tags) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: -8,
        children: tags.map((tag) {
          final isSelected = tag.contenu == _selectedTag;
          return ActionChip(
            label: Text(
              tag.contenu,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onPressed: () => _toggleTag(tag.contenu),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPagination(PaginatedRecipes data) {
    final totalPages = (data.total / data.limit).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? () => _loadRecipes(page: 1) : null,
            icon: const Icon(Icons.first_page),
            tooltip: 'Première page',
          ),
          IconButton(
            onPressed: _currentPage > 1 ? () => _loadRecipes(page: _currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Page précédente',
          ),
          const SizedBox(width: 16),
          Text(
            'Page $_currentPage sur $totalPages',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _currentPage < totalPages ? () => _loadRecipes(page: _currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Page suivante',
          ),
          IconButton(
            onPressed: _currentPage < totalPages ? () => _loadRecipes(page: totalPages) : null,
            icon: const Icon(Icons.last_page),
            tooltip: 'Dernière page',
          ),
        ],
      ),
    );
  }
}