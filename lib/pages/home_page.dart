import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/widget/carrousel_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(height: 100),
      body: Column(children: [Expanded(child: CarrouselWidget())]),
      bottomNavigationBar: const FooterWidget(),
    );
  }
}
