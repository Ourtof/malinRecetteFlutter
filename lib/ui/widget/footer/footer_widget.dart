import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/constants/app_colors.dart';
import 'package:malinrecetteflutter/ui/widget/navlink_widget.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      color: AppColors.neutral90,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 12 : 16,
        horizontal: isMobile ? 16 : 28,
      ),
      child: isMobile
          ? // Sur mobile : colonne avec liens en Wrap
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "© 2025 Malin'Recette",
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    NavLink(
                      label: 'Mentions légales',
                      textColor: AppColors.white,
                      onTap: () {
                        Navigator.of(context).pushNamed('/MentionsLegales');
                      },
                    ),
                    NavLink(
                      label: 'Qui sommes-nous ?',
                      textColor: AppColors.white,
                      onTap: () {
                        Navigator.of(context).pushNamed('/about');
                      },
                    ),
                    NavLink(
                      label: "Contact",
                      textColor: AppColors.white,
                      onTap: () {
                        Navigator.of(context).pushNamed('/contact');
                      },
                    ),
                  ],
                ),
              ],
            )
          : // Sur desktop/tablette : Row horizontal
          Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "© 2025 Malin'Recette",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
                Row(
                  children: [
                    NavLink(
                      label: 'Mentions légales',
                      textColor: AppColors.white,
                      onTap: () {
                        Navigator.of(context).pushNamed('/MentionsLegales');
                      },
                    ),
                    const SizedBox(width: 16),
                    NavLink(
                      label: 'Qui sommes-nous ?',
                      textColor: AppColors.white,
                      onTap: () {
                        Navigator.of(context).pushNamed('/about');
                      },
                    ),
                    const SizedBox(width: 16),
                    NavLink(
                      label: "Contact",
                      textColor: AppColors.white,
                      onTap: () {
                        Navigator.of(context).pushNamed('/contact');
                      },
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
