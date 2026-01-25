import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/utils/color_helpers.dart';

class AdminDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
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
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );
  }

  static DataRow buildDataRow({
    required BuildContext context,
    required int index,
    required List<DataCell> cells,
  }) {
    final theme = Theme.of(context);
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
      cells: cells,
    );
  }
}
