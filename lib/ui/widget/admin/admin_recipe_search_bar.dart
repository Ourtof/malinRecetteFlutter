import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_search_bar.dart';

class AdminRecipeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final Function(String) onSubmitted;

  const AdminRecipeSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AdminSearchBar(
      controller: controller,
      onClear: onClear,
      onSubmitted: onSubmitted,
      labelText: 'Rechercher par titre, contenu ou auteur',
    );
  }
}
