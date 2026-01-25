import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/models/paginated_admin_recipes.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_pagination.dart';

class AdminRecipePagination extends StatelessWidget {
  final PaginatedAdminRecipes data;
  final int currentPage;
  final Function(int) onPageChange;

  const AdminRecipePagination({
    super.key,
    required this.data,
    required this.currentPage,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    return AdminPagination(
      data: PaginatedData(total: data.total, limit: data.limit),
      currentPage: currentPage,
      onPageChange: onPageChange,
    );
  }
}
