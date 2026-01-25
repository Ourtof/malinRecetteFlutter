import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/models/admin_user.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_data_table.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_user_status_chip.dart';
import 'package:malinrecetteflutter/ui/widget/admin/admin_user_action_button.dart';
import 'package:malinrecetteflutter/pages/profile/profile_page.dart';

class AdminUserTable extends StatelessWidget {
  final List<AdminUser> users;
  final Set<int> updatingUserIds;
  final Function(AdminUser) onToggleUser;

  const AdminUserTable({
    super.key,
    required this.users,
    required this.updatingUserIds,
    required this.onToggleUser,
  });

  @override
  Widget build(BuildContext context) {
    return AdminDataTable(
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Pseudo')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Rôles')),
        DataColumn(label: Text('Statut')),
        DataColumn(label: Text('Actions')),
      ],
      rows: users.asMap().entries.map((entry) {
        final index = entry.key;
        final user = entry.value;
        final isUpdating = updatingUserIds.contains(user.id);

        return AdminDataTable.buildDataRow(
          context: context,
          index: index,
          cells: [
            DataCell(Text(user.id.toString())),
            DataCell(Text(user.pseudo)),
            DataCell(Text(user.email)),
            DataCell(Text(user.roles.join(', '))),
            DataCell(AdminUserStatusChip(enabled: user.enabled)),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.person, size: 20),
                    tooltip: 'Voir le profil',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(userId: user.id),
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AdminUserActionButton(
                    user: user,
                    isUpdating: isUpdating,
                    onToggle: () => onToggleUser(user),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}


