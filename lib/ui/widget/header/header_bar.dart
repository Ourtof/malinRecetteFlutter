import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/constants/app_colors.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_content.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  const HeaderBar({super.key, this.height = 80});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary80,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: HeaderContent(height: height),
        ),
      ),
    );
  }
}
