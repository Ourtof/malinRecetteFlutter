import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/constants/app_colors.dart';
import 'package:malinrecetteflutter/ui/widget/carrousel_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral90, // <-- supprime le filet blanc
      appBar: const HeaderBar(height: 100),
      body: SafeArea(
        bottom: false,
        child: ColoredBox(
          color: Colors.white, // on remet le body en blanc
          child: CarrouselWidget(),
        ),
      ),
      bottomNavigationBar: const FooterWidget(),
    );
  }
}
