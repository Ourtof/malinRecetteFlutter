import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/pages/about/about_page.dart';
import 'package:malinrecetteflutter/pages/admin/admin_user_list_page.dart';
import 'package:malinrecetteflutter/pages/contact/contact.dart';
import 'package:malinrecetteflutter/pages/mentions_legales/mentions_legales_page.dart';
import 'package:malinrecetteflutter/pages/profile/profile_page.dart';
import 'package:malinrecetteflutter/pages/home_page/home_page.dart';
import 'package:malinrecetteflutter/pages/login/login_page.dart';
import 'package:malinrecetteflutter/pages/recipe/recipe_page.dart';
import 'package:malinrecetteflutter/pages/register/register_page.dart';
import 'package:malinrecetteflutter/constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Malin'Recette",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.neutral20,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/home_page': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/profile': (context) => const ProfilePage(),
        '/recette': (context) => const RecipePage(),
        '/admin/users': (context) => const AdminUserListPage(),
        '/MentionsLegales': (context) => const MentionsLegalesPage(),
        '/about': (context) => const AboutPage(),
        '/contact': (context) => const ContactPage(),
      },
    );
  }
}
