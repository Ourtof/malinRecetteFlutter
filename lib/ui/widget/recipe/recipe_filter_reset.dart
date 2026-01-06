import 'package:flutter/material.dart';

class RecipeFilterReset extends StatelessWidget {
  final VoidCallback onReset;

  const RecipeFilterReset({
    super.key,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.filter_alt_off, size: 16),
          label: const Text(
            'Réinitialiser les filtres',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            visualDensity: VisualDensity.compact,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.06),
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

