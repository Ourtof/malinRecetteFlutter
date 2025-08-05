import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/constants/app_colors.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.10,
      width: double.infinity,
      child: Container(
        color: AppColors.primary80,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Image.asset(
                'assets/img/logo_transparent.png',
                height: screenHeight * 0.06,
              ),
            ),
            Row(
              children: [
                SizedBox(width: 24),
                Text(
                  'Accueil',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(width: 24),
                Text(
                  'Recettes',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(width: 24),
                Text(
                  'À propos',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(width: 24),
                Icon(Icons.account_circle, color: Colors.black),
                SizedBox(width: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
