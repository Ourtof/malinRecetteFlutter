import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/utils/color_helpers.dart';

class AdminUserStatusChip extends StatelessWidget {
  final bool enabled;

  const AdminUserStatusChip({
    super.key,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = enabled ? theme.colorScheme.primary : theme.colorScheme.error;
    final bgColor = ColorHelpers.withOpacity(color, 0.12);
    final label = enabled ? 'Actif' : 'Inactif';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

