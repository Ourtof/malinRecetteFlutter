import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/api/api_service_factory.dart';
import 'package:malinrecetteflutter/models/admin_user.dart';
import 'package:malinrecetteflutter/repositories/admin_repository.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/utils/snackbar_helpers.dart';
import 'package:malinrecetteflutter/utils/string_helpers.dart';
import 'package:malinrecetteflutter/utils/color_helpers.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_page_header.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_user_search_bar.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_user_count_bar.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_user_status_chip.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_user_action_button.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_error_widget.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  bool _isLoading = false;
  String? _error;
  List<AdminUser> _users = [];
  final Set<int> _updatingUserIds = {};

  // Recherche
  String _search = '';
  final TextEditingController _searchController = TextEditingController();

  late final AdminRepository _adminRepository;

  @override
  void initState() {
    super.initState();
    _adminRepository = AdminRepository(
      apiService: ApiServiceFactory.create(),
    );
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({String? search}) async {
    final effectiveSearch = search ?? _search;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _adminRepository.getUsers(
        search: StringHelpers.nullIfEmpty(effectiveSearch),
      );

      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
        _search = effectiveSearch;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur de chargement : $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleUser(AdminUser user) async {
    final newStatus = !user.enabled;

    setState(() {
      _updatingUserIds.add(user.id);
    });

    try {
      final updatedUser = await _adminRepository.toggleUserEnabled(
        user.id,
        newStatus,
      );

      if (mounted) {
        setState(() {
          final index = _users.indexWhere((u) => u.id == updatedUser.id);
          if (index != -1) {
            _users[index] = updatedUser;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelpers.showError(context, 'Erreur : $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingUserIds.remove(user.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                ),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildTableContent(theme),
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

  Widget _buildTableContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return AdminErrorWidget(
        error: _error!,
        onRetry: () => _loadUsers(search: ''),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Text(
          'Aucun utilisateur à afficher.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminUserSearchBar(
          controller: _searchController,
          onClear: () {
            _searchController.clear();
            _loadUsers(search: '');
          },
          onSubmitted: (value) => _loadUsers(search: value.trim()),
        ),
        const SizedBox(height: 12),
        AdminUserCountBar(
          count: _users.length,
          onRefresh: () => _loadUsers(search: _search),
        ),
        const SizedBox(height: 8),

        // Tableau
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 32,
                  headingTextStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  headingRowColor: WidgetStateProperty.all(
                    ColorHelpers.withOpacity(theme.colorScheme.surfaceContainerHighest, 0.8),
                  ),
                  dataRowMinHeight: 48,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: ColorHelpers.withOpacity(theme.dividerColor, 0.3),
                      width: 0.5,
                    ),
                  ),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Pseudo')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Rôles')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: _users.asMap().entries.map((entry) {
                    final index = entry.key;
                    final user = entry.value;
                    final isUpdating = _updatingUserIds.contains(user.id);

                    return DataRow(
                      color: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.hovered)) {
                          return ColorHelpers.withOpacity(theme.colorScheme.primary, 0.04);
                        }
                        if (index.isEven) {
                          return ColorHelpers.withOpacity(
                            theme.colorScheme.surfaceContainerHighest,
                            0.25,
                          );
                        }
                        return Colors.transparent;
                      }),
                      cells: [
                        DataCell(Text(user.id.toString())),
                        DataCell(Text(user.pseudo)),
                        DataCell(Text(user.email)),
                        DataCell(Text(user.roles.join(', '))),
                        DataCell(AdminUserStatusChip(enabled: user.enabled)),
                        DataCell(AdminUserActionButton(
                          user: user,
                          isUpdating: isUpdating,
                          onToggle: () => _toggleUser(user),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}
