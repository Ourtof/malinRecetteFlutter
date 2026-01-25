import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class FoodProfileSummaryCard extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final String goalTypeLabel;
  final String dietTypeLabel;
  final bool isHalal;
  final String allergiesLabel;
  final bool isSaving;
  final VoidCallback? onEdit;

  const FoodProfileSummaryCard({
    super.key,
    required this.isLoading,
    this.error,
    required this.goalTypeLabel,
    required this.dietTypeLabel,
    required this.isHalal,
    required this.allergiesLabel,
    required this.isSaving,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profil alimentaire',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (error != null) ...[
                    Text(
                      error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildSummaryRow('Objectif', goalTypeLabel),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Régime', dietTypeLabel),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Halal', isHalal ? 'Oui' : 'Non'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Allergies', allergiesLabel),
                  if (onEdit != null) ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: isSaving ? null : onEdit,
                        icon: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.restaurant_menu, size: 18),
                        label: Text(
                          isSaving ? 'Enregistrement...' : 'Modifier le profil alimentaire',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(value, style: const TextStyle(color: AppColors.black)),
        ],
      ),
    );
  }
}


