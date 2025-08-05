import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/widget/carrousel_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header_widget.dart';
import 'package:malinrecetteflutter/ui/widget/footer_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderWidget(), // 👈 hauteur fixe obligatoire
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white, // optionnel : pour voir la zone
              child: CarrouselWidget(),
            ),
          ),
          const FooterWidget(),
        ],
      ),
    );
  }
}
