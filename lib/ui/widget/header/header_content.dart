import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';
import 'package:malinrecetteflutter/ui/widget/navlink_widget.dart';

class HeaderContent extends StatefulWidget {
  final double height;
  const HeaderContent({super.key, required this.height});

  @override
  State<HeaderContent> createState() => _HeaderContentState();
}

class _HeaderContentState extends State<HeaderContent> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadAdminStatus();
  }

  Future<void> _loadAdminStatus() async {
    final isAdmin = await AuthService.isAdmin();
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32),
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
                  Navigator.of(
                    context,
                  ).pushNamed(isLogged ? '/profile' : '/login');
                },
                mouseCursor: SystemMouseCursors.click,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.account_circle, color: Colors.black),
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
