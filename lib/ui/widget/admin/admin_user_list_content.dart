import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/models/paginated_users.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_user_search_bar.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_user_count_bar.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_user_table.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_user_pagination.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_error_widget.dart';
import 'package:malinrecetteflutter/models/admin_user.dart';

class AdminUserListContent extends StatelessWidget {
  final Future<PaginatedUsers>? futureUsers;
  final TextEditingController searchController;
  final int currentPage;
  final Set<int> updatingUserIds;
  final Function(String) onSearchSubmitted;
  final VoidCallback onSearchClear;
  final VoidCallback onRefresh;
  final Function(int) onPageChange;
  final Function(AdminUser) onToggleUser;

  const AdminUserListContent({
    super.key,
    required this.futureUsers,
    required this.searchController,
    required this.currentPage,
    required this.updatingUserIds,
    required this.onSearchSubmitted,
    required this.onSearchClear,
    required this.onRefresh,
    required this.onPageChange,
    required this.onToggleUser,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaginatedUsers>(
      future: futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return AdminErrorWidget(
            error: 'Erreur de chargement : ${snapshot.error}',
            onRetry: onRefresh,
          );
        }

        final paginatedUsers = snapshot.data;
        if (paginatedUsers == null || paginatedUsers.items.isEmpty) {
          return Center(
            child: Text(
              'Aucun utilisateur à afficher.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminUserSearchBar(
              controller: searchController,
              onClear: onSearchClear,
              onSubmitted: onSearchSubmitted,
            ),
            const SizedBox(height: 12),
            AdminUserCountBar(
              count: paginatedUsers.total,
              onRefresh: onRefresh,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AdminUserTable(
                users: paginatedUsers.items,
                updatingUserIds: updatingUserIds,
                onToggleUser: onToggleUser,
              ),
            ),
            AdminUserPagination(
              data: paginatedUsers,
              currentPage: currentPage,
              onPageChange: onPageChange,
            ),
          ],
        );
      },
    );
  }
}


