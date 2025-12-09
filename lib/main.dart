import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/pages/profile/profile_page.dart';
import 'package:malinrecetteflutter/pages/home_page.dart';
import 'package:malinrecetteflutter/pages/login_page.dart';
import 'package:malinrecetteflutter/pages/recipe/recipe_page.dart';
import 'package:malinrecetteflutter/pages/register_page.dart';
import 'package:malinrecetteflutter/ui/constants/app_colors.dart';

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
      },
    );
  }
}
