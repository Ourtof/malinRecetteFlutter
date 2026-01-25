import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/utils/color_helpers.dart';

class AdminCountBar extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback onRefresh;

  const AdminCountBar({
    super.key,
    required this.count,
    required this.label,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count $label',
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
