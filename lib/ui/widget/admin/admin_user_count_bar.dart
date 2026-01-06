import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/utils/color_helpers.dart';

class AdminUserCountBar extends StatelessWidget {
  final int count;
  final VoidCallback onRefresh;

  const AdminUserCountBar({
    super.key,
    required this.count,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count utilisateur(s)',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorHelpers.withOpacity(theme.colorScheme.onSurface, 0.7),
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          tooltip: 'Rafraîchir',
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}


