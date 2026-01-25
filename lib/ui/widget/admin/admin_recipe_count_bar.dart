import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_count_bar.dart';

class AdminRecipeCountBar extends StatelessWidget {
  final int count;
  final VoidCallback onRefresh;

  const AdminRecipeCountBar({
    super.key,
    required this.count,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCountBar(
      count: count,
      label: 'recette(s)',
      onRefresh: onRefresh,
    );
  }
}
