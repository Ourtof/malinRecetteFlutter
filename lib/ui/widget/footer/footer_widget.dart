import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/constants/app_colors.dart';
import 'package:malinrecetteflutter/ui/widget/Navlink_widget.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.neutral90,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("© 2025 Malin'Recette"),
          Row(
            children: [
              NavLink(
                label: 'Mentions légales',
                onTap: () {
                  Navigator.of(context).pushNamed('/MentionsLegales');
                },
              ),
              const SizedBox(width: 16),
              //const Text('Contact', style: TextStyle(color: Colors.white)),
              NavLink(
                label: 'Qui sommes-nous ?',
                onTap: () {
                  Navigator.of(context).pushNamed('/about');
                },
              ),
              NavLink(
                label: "Contact",
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
