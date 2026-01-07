import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';
import 'package:malinrecetteflutter/ui/widget/navlink_widget.dart';

import '../../../constants/app_colors.dart';

class HeaderContent extends StatefulWidget {
  final double height;
  const HeaderContent({super.key, required this.height});

  @override
  State<HeaderContent> createState() => _HeaderContentState();
}

class _HeaderContentState extends State<HeaderContent> {
  bool _isAdmin = false;
  bool _isLogged = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final isAdmin = await AuthService.isAdmin();
    final isLogged = await AuthService.isLoggedIn();
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
      _isLogged = isLogged;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.0 : 24.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: isMobile ? 0 : 32,
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('/home_page');
              },
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/img/logo_transparent.png',
                height: widget.height * 0.9,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (isMobile)
            // Sur mobile : icônes seulement
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: AppColors.black),
                  tooltip: 'Accueil',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.restaurant_menu, color: AppColors.black),
                  tooltip: 'Recettes',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/recette');
                  },
                ),
                if (_isAdmin)
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings, color: AppColors.black),
                    tooltip: 'Administration',
                    onPressed: () {
                      Navigator.of(context).pushNamed('/admin/users');
                    },
                  ),
                IconButton(
                  icon: Icon(
                    _isLogged ? Icons.person : Icons.login,
                    color: AppColors.black,
                  ),
                  tooltip: _isLogged ? 'Profil' : 'Connexion',
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      _isLogged ? '/profile' : '/login',
                    );
                  },
                ),
              ],
            )
          else
            // Sur desktop/tablette : navigation avec textes
            Row(
              children: [
                const SizedBox(width: 24),
                NavLink(
                  label: 'Accueil',
                  onTap: () {
                    Navigator.of(context).pushNamed('/');
                  },
                ),
                const SizedBox(width: 8),
                NavLink(
                  label: 'Recettes',
                  onTap: () {
                    Navigator.of(context).pushNamed('/recette');
                  },
                ),
                const SizedBox(width: 8),
                if (_isAdmin) ...[
                  const SizedBox(width: 8),
                  NavLink(
                    label: 'Administration',
                    onTap: () {
                      Navigator.of(context).pushNamed('/admin/users');
                    },
                  ),
                ],
                const SizedBox(width: 16),
                InkWell(
                  onTap: () async {
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
                ),
                const SizedBox(width: 24),
              ],
            ),
        ],
      ),
    );
  }
}
