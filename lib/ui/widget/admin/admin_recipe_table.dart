import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/models/admin_recipe.dart';
import 'package:malinrecetteflutter/utils/color_helpers.dart';
import 'package:malinrecetteflutter/utils/date_formatter.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_recipe_action_button.dart';

class AdminRecipeTable extends StatelessWidget {
  final List<AdminRecipe> recipes;
  final Set<int> deletingRecipeIds;
  final Function(AdminRecipe) onDelete;
  final Function(AdminRecipe) onEdit;
  final Function(AdminRecipe) onView;

  const AdminRecipeTable({
    super.key,
    required this.recipes,
    required this.deletingRecipeIds,
    required this.onDelete,
    required this.onEdit,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 32,
            headingTextStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            headingRowColor: WidgetStateProperty.all(
              ColorHelpers.withOpacity(theme.colorScheme.surfaceContainerHighest, 0.8),
            ),
            dataRowMinHeight: 48,
            border: TableBorder(
              horizontalInside: BorderSide(
                color: ColorHelpers.withOpacity(theme.dividerColor, 0.3),
                width: 0.5,
              ),
            ),
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Titre')),
              DataColumn(label: Text('Auteur')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Tags')),
              DataColumn(label: Text('Actions')),
            ],
            rows: recipes.asMap().entries.map((entry) {
              final index = entry.key;
              final recipe = entry.value;
              final isDeleting = deletingRecipeIds.contains(recipe.id);

              return DataRow(
                color: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return ColorHelpers.withOpacity(theme.colorScheme.primary, 0.04);
                  }
                  if (index.isEven) {
                    return ColorHelpers.withOpacity(
                      theme.colorScheme.surfaceContainerHighest,
                      0.25,
                    );
                  }
                  return Colors.transparent;
                }),
                cells: [
                  DataCell(Text(recipe.id.toString())),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(
                        recipe.titre,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(recipe.auteur?.pseudo ?? 'Ancien utilisateur'),
                  ),
                  DataCell(
                    Text(
                      recipe.dateRecette != null
                          ? DateFormatter.formatDate(recipe.dateRecette!)
                          : 'N/A',
                    ),
                  ),
                  DataCell(
                    Text(
                      recipe.tags.isEmpty
                          ? 'Aucun'
                          : recipe.tags.map((t) => t.contenu).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    AdminRecipeActionButton(
                      recipe: recipe,
                      isDeleting: isDeleting,
                      onDelete: () => onDelete(recipe),
                      onEdit: () => onEdit(recipe),
                      onView: () => onView(recipe),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
