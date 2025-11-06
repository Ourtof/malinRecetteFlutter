import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/constants/app_colors.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.neutral90,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("© 2025 Malin'Recette", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Mentions légales', style: TextStyle(color: Colors.white)),
              SizedBox(width: 16),
              Text('Contact', style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
