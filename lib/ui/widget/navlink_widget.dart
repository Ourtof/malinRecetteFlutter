import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const NavLink({super.key, required this.label, required this.onTap});

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
          style: const TextStyle(color: AppColors.black, fontSize: 18),
        ),
      ),
    );
  }
}
