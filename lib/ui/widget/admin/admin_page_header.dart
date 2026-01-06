import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/utils/color_helpers.dart';

class AdminPageHeader extends StatelessWidget {
  final String title;
  final String description;

  const AdminPageHeader({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorHelpers.withOpacity(theme.colorScheme.onSurface, 0.7),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}


