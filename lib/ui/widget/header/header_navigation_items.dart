import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/constants/app_colors.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';
import 'package:malinrecetteflutter/ui/widget/navlink_widget.dart';

class NavigationItem {
  final String label;
  final String route;
  final IconData icon;
  final bool requiresAdmin;

  const NavigationItem({
    required this.label,
    required this.route,
    required this.icon,
    this.requiresAdmin = false,
  });
}

// nav du header
class HeaderNavigationItems extends StatelessWidget {
  final bool isMobile;
  final bool isAdmin;
  final bool isLogged;

  const HeaderNavigationItems({
    super.key,
    required this.isMobile,
    required this.isAdmin,
    required this.isLogged,
  });

  static const List<NavigationItem> _items = [
    NavigationItem(
      label: 'Accueil',
      route: '/',
      icon: Icons.home,
    ),
    NavigationItem(
      label: 'Recettes',
      route: '/recette',
      icon: Icons.restaurant_menu,
    ),
    NavigationItem(
      label: 'Administration',
      route: '/admin/users',
      icon: Icons.admin_panel_settings,
      requiresAdmin: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleItems = _items.where((item) {
      if (item.requiresAdmin && !isAdmin) return false;
      return true;
    }).toList();

    if (isMobile) {
      return Row(
        children: visibleItems
            .map((item) => _buildMobileItem(context, item))
            .toList()
          ..add(_buildProfileButton(context)),
      );
    }

    return Row(
      children: [
        const SizedBox(width: 24),
        ...visibleItems
            .expand((item) => [
                  NavLink(
                    label: item.label,
                    onTap: () {
                      Navigator.of(context).pushNamed(item.route);
                    },
                  ),
                  const SizedBox(width: 8),
                ])
            .take(visibleItems.length * 2 - 1),
        const SizedBox(width: 16),
        _buildProfileButton(context),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildMobileItem(BuildContext context, NavigationItem item) {
    return IconButton(
      icon: Icon(item.icon, color: AppColors.black, size: 32),
      iconSize: 28,
      padding: const EdgeInsets.all(16),
      tooltip: item.label,
      onPressed: () {
        Navigator.of(context).pushNamed(item.route);
      },
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    if (isMobile) {
      return IconButton(
        icon: Icon(
          isLogged ? Icons.person : Icons.login,
          color: AppColors.black,
          size: 32,
        ),
        iconSize: 28,
        padding: const EdgeInsets.all(16),
        tooltip: isLogged ? 'Profil' : 'Connexion',
        onPressed: () {
          Navigator.of(context).pushNamed(
            isLogged ? '/profile' : '/login',
          );
        },
      );
    }

    return InkWell(
      onTap: () async {
        // Recharger le statut pour être sûr
        final isLogged = await AuthService.isLoggedIn();
        Navigator.of(context).pushNamed(
          isLogged ? '/profile' : '/login',
        );
      },
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(8),
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.account_circle, color: AppColors.black),
      ),
    );
  }
}

