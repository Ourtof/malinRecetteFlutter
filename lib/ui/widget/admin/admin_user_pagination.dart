import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/models/paginated_users.dart';

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
    final totalPages = (data.total / data.limit).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1 ? () => onPageChange(1) : null,
            icon: const Icon(Icons.first_page),
            tooltip: 'Première page',
          ),
          IconButton(
            onPressed: currentPage > 1 ? () => onPageChange(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Page précédente',
          ),
          const SizedBox(width: 16),
          Text(
            'Page $currentPage sur $totalPages',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: currentPage < totalPages ? () => onPageChange(currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Page suivante',
          ),
          IconButton(
            onPressed: currentPage < totalPages ? () => onPageChange(totalPages) : null,
            icon: const Icon(Icons.last_page),
            tooltip: 'Dernière page',
          ),
        ],
      ),
    );
  }
}


