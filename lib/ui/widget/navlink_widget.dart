import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final double? fontSize;

  const NavLink({
    super.key,
    required this.label,
    required this.onTap,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 6 : 8,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? AppColors.black,
            fontSize: fontSize ?? (isMobile ? 14 : 18),
          ),
        ),
      ),
    );
  }
}
