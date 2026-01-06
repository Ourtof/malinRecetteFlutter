import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/models/admin_user.dart';

class AdminUserActionButton extends StatelessWidget {
  final AdminUser user;
  final bool isUpdating;
  final VoidCallback onToggle;

  const AdminUserActionButton({
    super.key,
    required this.user,
    required this.isUpdating,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isUpdating) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final isActive = user.enabled;

    Future<void> handleTap() async {
      if (isActive) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Désactiver le compte ?'),
              content: Text(
                'Tu es sûr de vouloir désactiver le compte "${user.pseudo}" ? '
                'Il ne pourra plus se connecter.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Désactiver'),
                ),
              ],
            );
          },
        );

        if (confirm != true) return;
      }

      onToggle();
    }

    return TextButton.icon(
      onPressed: handleTap,
      icon: Icon(isActive ? Icons.block : Icons.check_circle_outline, size: 18),
      label: Text(isActive ? 'Désactiver' : 'Réactiver'),
      style: TextButton.styleFrom(
        foregroundColor: isActive
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}


