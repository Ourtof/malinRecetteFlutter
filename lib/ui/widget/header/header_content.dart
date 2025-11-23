import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';

class HeaderContent extends StatelessWidget {
  final double height;
  const HeaderContent({super.key, required this.height});

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
                height: height * 0.9,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 24),
              _NavLink(
                label: 'Accueil',
                onTap: () {
                  Navigator.of(context).pushNamed('/');
                },
              ),
              const SizedBox(width: 8),
              _NavLink(
                label: 'Recettes',
                onTap: () {
                  Navigator.of(context).pushNamed('/recipes');
                },
              ),
              const SizedBox(width: 8),
              _NavLink(
                label: 'À propos',
                onTap: () {
                  Navigator.of(context).pushNamed('/about');
                },
              ),
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

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
    );
  }
}
