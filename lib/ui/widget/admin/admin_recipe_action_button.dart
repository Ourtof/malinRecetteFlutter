import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/models/admin_recipe.dart';

class AdminRecipeActionButton extends StatelessWidget {
  final AdminRecipe recipe;
  final bool isDeleting;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onView;

  const AdminRecipeActionButton({
    super.key,
    required this.recipe,
    required this.isDeleting,
    required this.onDelete,
    required this.onEdit,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Future<void> handleDelete() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Supprimer la recette ?'),
            content: Text(
              'Tu es sûr de vouloir supprimer la recette "${recipe.titre}" ? '
              'Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        onDelete();
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility, size: 20),
          tooltip: 'Consulter',
          onPressed: onView,
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          tooltip: 'Modifier',
          onPressed: onEdit,
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
          ),
        ),
        const SizedBox(width: 4),
        if (isDeleting)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            tooltip: 'Supprimer',
            onPressed: handleDelete,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              foregroundColor: theme.colorScheme.error,
            ),
          ),
      ],
    );
  }
}
