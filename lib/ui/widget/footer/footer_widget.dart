import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/constants/app_colors.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_links.dart';
import 'package:malinrecetteflutter/utils/responsive_helpers.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelpers.isMobile(context);

    return Container(
      width: double.infinity,
      color: AppColors.neutral90,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 12 : 16,
        horizontal: isMobile ? 16 : 28,
      ),
      child: isMobile
          ?
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "© 2025 Malin'Recette",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                FooterLinks(isMobile: true),
              ],
            )
          : // Sur desktop/tablette : Row horizontal
          Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "© 2025 Malin'Recette",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
                FooterLinks(isMobile: false),
              ],
            ),
    );
  }
}
