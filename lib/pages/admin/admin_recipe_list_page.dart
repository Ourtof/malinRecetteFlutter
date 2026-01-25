import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/api/api_service_factory.dart';
import 'package:malinrecetteflutter/models/admin_recipe.dart';
import 'package:malinrecetteflutter/models/paginated_admin_recipes.dart';
import 'package:malinrecetteflutter/repositories/admin_repository.dart';
import 'package:malinrecetteflutter/utils/snackbar_helpers.dart';
import 'package:malinrecetteflutter/utils/string_helpers.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_page_layout.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_recipe_list_content.dart';
import 'package:malinrecetteflutter/pages/recipe/recipe_detail_page.dart';
import 'package:malinrecetteflutter/pages/recipe/edit_recipe_page.dart';
import 'package:malinrecetteflutter/models/recipe.dart';

class AdminRecipeListPage extends StatefulWidget {
  const AdminRecipeListPage({super.key});

  @override
  State<AdminRecipeListPage> createState() => _AdminRecipeListPageState();
}

class _AdminRecipeListPageState extends State<AdminRecipeListPage> {
  final Set<int> _deletingRecipeIds = {};
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  Future<PaginatedAdminRecipes>? _futureRecipes;

  late final AdminRepository _adminRepository;

  @override
  void initState() {
    super.initState();
    _adminRepository = AdminRepository(
      apiService: ApiServiceFactory.create(),
    );
    _loadRecipes();
  }

  void _loadRecipes({int page = 1, String? search}) {
    _currentPage = page;
    final effectiveSearch = search ?? _searchController.text.trim();

    setState(() {
      _futureRecipes = _adminRepository.getRecipes(
        search: StringHelpers.nullIfEmpty(effectiveSearch),
        page: _currentPage,
      );
    });
  }

  void _resetSearch() {
    _searchController.clear();
    _loadRecipes(page: 1, search: '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteRecipe(AdminRecipe recipe) async {
    setState(() => _deletingRecipeIds.add(recipe.id));

    try {
      await _adminRepository.deleteRecipe(recipe.id);

      if (!mounted) return;

      SnackbarHelpers.showSuccess(context, 'Recette supprimée avec succès');
      _loadRecipes(page: _currentPage);
    } catch (e) {
      if (mounted) {
        SnackbarHelpers.showError(context, 'Erreur : $e');
      }
    } finally {
      if (mounted) {
        setState(() => _deletingRecipeIds.remove(recipe.id));
      }
    }
  }

  void _viewRecipe(AdminRecipe adminRecipe) {
    final recipe = _convertToRecipe(adminRecipe);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(recipe: recipe),
      ),
    );
  }

  void _editRecipe(AdminRecipe adminRecipe) {
    final recipe = _convertToRecipe(adminRecipe);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditRecipePage(recipe: recipe),
      ),
    ).then((_) {
      // Recharger après édition
      _loadRecipes(page: _currentPage);
    });
  }

  Recipe _convertToRecipe(AdminRecipe adminRecipe) {
    return Recipe(
      id: adminRecipe.id,
      titre: adminRecipe.titre,
      contenu: adminRecipe.contenu,
      dateRecette: adminRecipe.dateRecette,
      auteur: adminRecipe.auteur,
      illustration: adminRecipe.illustration,
      tags: adminRecipe.tags,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageLayout(
      title: 'Gestion des recettes',
      description: "Vue d'ensemble des recettes et possibilités de gestion.",
      showBackButton: true,
      content: _buildTableContent(),
    );
  }

  Widget _buildTableContent() {
    return AdminRecipeListContent(
      futureRecipes: _futureRecipes,
      searchController: _searchController,
      currentPage: _currentPage,
      deletingRecipeIds: _deletingRecipeIds,
      onSearchSubmitted: (value) => _loadRecipes(page: 1, search: value),
      onSearchClear: _resetSearch,
      onRefresh: () => _loadRecipes(page: _currentPage),
      onPageChange: (page) => _loadRecipes(page: page),
      onDelete: _deleteRecipe,
      onEdit: _editRecipe,
      onView: _viewRecipe,
    );
  }
}
