import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:malinrecetteflutter/config/api_config.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminUser {
  final int id;
  final String email;
  final String pseudo;
  final List<String> roles;
  final bool enabled;

  const AdminUser({
    required this.id,
    required this.email,
    required this.pseudo,
    required this.roles,
    required this.enabled,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      pseudo: json['pseudo'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  AdminUser copyWith({
    int? id,
    String? email,
    String? pseudo,
    List<String>? roles,
    bool? enabled,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      pseudo: pseudo ?? this.pseudo,
      roles: roles ?? this.roles,
      enabled: enabled ?? this.enabled,
    );
  }
}

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  bool _isLoading = false;
  String? _error;
  List<AdminUser> _users = [];
  final Set<int> _updatingUserIds = {};

  // Recherche
  String _search = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      // croix
      setState(() {});
    });
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _loadUsers({String? search}) async {
    final effectiveSearch = search ?? _search;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _getToken();
      if (token == null) {
        if (!mounted) return;
        setState(() {
          _error = 'Token introuvable. Merci de te reconnecter.';
          _isLoading = false;
        });
        return;
      }

      final queryParams = <String, String>{};
      if (effectiveSearch.isNotEmpty) {
        queryParams['search'] = effectiveSearch;
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/admin/user',
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> rawList = (data is List)
            ? data
            : (data['items'] as List<dynamic>);

        final users = rawList
            .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
            .toList();

        if (!mounted) return;
        setState(() {
          _users = users;
          _isLoading = false;
          _search = effectiveSearch;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Erreur serveur (${response.statusCode}) : ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur de chargement : $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleUser(AdminUser user) async {
    final newStatus = !user.enabled;

    setState(() {
      _updatingUserIds.add(user.id);
    });

    try {
      final token = await _getToken();
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token manquant, reconnecte-toi.')),
        );
        return;
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/admin/user/${user.id}/toggle-enabled',
      );
      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'enabled': newStatus}),
      );
      if (response.statusCode == 200) {
        final updatedJson = jsonDecode(response.body) as Map<String, dynamic>;
        final updatedUser = AdminUser.fromJson(updatedJson);

        if (!mounted) return;
        setState(() {
          _users = _users
              .map((u) => u.id == updatedUser.id ? updatedUser : u)
              .toList();
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la mise à jour (${response.statusCode}).'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _updatingUserIds.remove(user.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const HeaderBar(height: 88),
      bottomNavigationBar: const FooterWidget(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion des utilisateurs',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vue d’ensemble des comptes et de leur statut.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildTableContent(theme),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadUsers(search: ''),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Text(
          'Aucun utilisateur à afficher.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher par pseudo ou email',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _loadUsers(search: '');
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (value) {
                  _loadUsers(search: value.trim());
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 12),

        // ---- Ligne compteur + bouton refresh ----
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_users.length} utilisateur(s)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            IconButton(
              onPressed: () => _loadUsers(search: _search),
              tooltip: 'Rafraîchir',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ---- Tableau ----
        Expanded(
          child: Scrollbar(
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
                  headingRowColor: MaterialStatePropertyAll(
                    theme.colorScheme.surfaceVariant.withOpacity(0.8),
                  ),
                  dataRowMinHeight: 48,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: theme.dividerColor.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Pseudo')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Rôles')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: _users.asMap().entries.map((entry) {
                    final index = entry.key;
                    final user = entry.value;
                    final isUpdating = _updatingUserIds.contains(user.id);

                    return DataRow(
                      color: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return theme.colorScheme.primary.withOpacity(0.04);
                        }
                        // zébrage léger
                        return index.isEven
                            ? theme.colorScheme.surfaceVariant.withOpacity(0.25)
                            : Colors.transparent;
                      }),
                      cells: [
                        DataCell(Text(user.id.toString())),
                        DataCell(Text(user.pseudo)),
                        DataCell(Text(user.email)),
                        DataCell(Text(user.roles.join(', '))),
                        DataCell(_buildStatusChip(user.enabled, theme)),
                        DataCell(_buildActionButton(user, isUpdating, theme)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool enabled, ThemeData theme) {
    final color = enabled ? theme.colorScheme.primary : theme.colorScheme.error;
    final bgColor = color.withOpacity(0.12);
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

  Widget _buildActionButton(AdminUser user, bool isUpdating, ThemeData theme) {
    if (isUpdating) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final isActive = user.enabled;

    Future<void> handleTap() async {
      // Confirmation uniquement pour la désactivation
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

      await _toggleUser(user);
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
