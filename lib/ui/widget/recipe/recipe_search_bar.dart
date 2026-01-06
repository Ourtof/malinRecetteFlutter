import 'package:flutter/material.dart';

class RecipeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final VoidCallback onSubmitted;

  const RecipeSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Rechercher une recette...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: onClear,
          ),
        ),
        onSubmitted: (_) => onSubmitted(),
      ),
    );
  }
}

