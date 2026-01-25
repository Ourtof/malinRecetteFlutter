import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/models/paginated_users.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_pagination.dart';

class AdminUserPagination extends StatelessWidget {
  final PaginatedUsers data;
  final int currentPage;
  final Function(int) onPageChange;

  const AdminUserPagination({
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


