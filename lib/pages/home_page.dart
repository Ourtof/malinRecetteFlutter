import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/widget/header_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          HeaderWidget(),
          Expanded(child: Center(child: Text('contenu'))),
        ],
      ),
    );
  }
}