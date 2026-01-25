import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/api/api_service_factory.dart';
import 'package:malinrecetteflutter/models/admin_user.dart';
import 'package:malinrecetteflutter/models/paginated_users.dart';
import 'package:malinrecetteflutter/repositories/admin_repository.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/utils/snackbar_helpers.dart';
import 'package:malinrecetteflutter/utils/string_helpers.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_page_header.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_user_list_content.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  final Set<int> _updatingUserIds = {};
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  Future<PaginatedUsers>? _futureUsers;

  late final AdminRepository _adminRepository;

  @override
  void initState() {
    super.initState();
    _adminRepository = AdminRepository(
      apiService: ApiServiceFactory.create(),
    );
    _loadUsers();
  }

  void _loadUsers({int page = 1, String? search}) {
    _currentPage = page;
    final effectiveSearch = search ?? _searchController.text.trim();

    setState(() {
      _futureUsers = _adminRepository.getUsers(
        search: StringHelpers.nullIfEmpty(effectiveSearch),
        page: _currentPage,
      );
    });
  }

  void _resetSearch() {
    _searchController.clear();
    _loadUsers(page: 1, search: '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  Future<void> _toggleUser(AdminUser user) async {
    setState(() => _updatingUserIds.add(user.id));

    try {
      await _adminRepository.toggleUserEnabled(
        user.id,
        !user.enabled,
      );

      if (!mounted) return;

      // Recharger la page actuelle pour mettre à jour les données
      _loadUsers(page: _currentPage);
    } catch (e) {
      if (mounted) {
        SnackbarHelpers.showError(context, 'Erreur : $e');
      }
    } finally {
      if (mounted) {
        setState(() => _updatingUserIds.remove(user.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(height: 88),
      bottomNavigationBar: const FooterWidget(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminPageHeader(
                  title: 'Gestion des utilisateurs',
                  description: "Vue d'ensemble des comptes et de leur statut.",
                  showBackButton: true,
                ),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildTableContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableContent() {
    return AdminUserListContent(
      futureUsers: _futureUsers,
      searchController: _searchController,
      currentPage: _currentPage,
      updatingUserIds: _updatingUserIds,
      onSearchSubmitted: (value) => _loadUsers(page: 1, search: value),
      onSearchClear: _resetSearch,
      onRefresh: () => _loadUsers(page: _currentPage),
      onPageChange: (page) => _loadUsers(page: page),
      onToggleUser: _toggleUser,
    );
  }

}
