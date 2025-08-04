import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.10,
      width: double.infinity,
      child: Container(
        color: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo.png', height: screenHeight * 0.06),
            Row(
              children: const [
                SizedBox(width: 16),
                Text(
                  'Accueil',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(width: 16),
                Text(
                  'À propos',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(width: 16),
                Text(
                  'Contact',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
