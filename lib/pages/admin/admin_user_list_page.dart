import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';

class AdminUserListPage extends StatelessWidget {
  const AdminUserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(height: 88),
      bottomNavigationBar: const FooterWidget(),
      body: const Center(
        child: Text(
          'Administration utilisateurs\n(Bloc 4 : liste + actions)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
