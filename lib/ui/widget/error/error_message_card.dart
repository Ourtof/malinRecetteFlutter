import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/constants/app_colors.dart';

/// Widget réutilisable pour afficher les messages d'erreur de manière élégante
class ErrorMessageCard extends StatelessWidget {
  final String message;

  const ErrorMessageCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final hasDetails = message.contains('\n');
    final title = hasDetails ? message.split('\n').first : message;
    final details = hasDetails ? message.split('\n').skip(1).toList() : <String>[];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (hasDetails) ...[
            const SizedBox(height: 12),
            ...details.map((line) => Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    bottom: 4,
                  ),
                  child: Text(
                    line,
                    style: TextStyle(
                      color: AppColors.error.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
