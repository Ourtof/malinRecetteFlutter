import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/config/api_config.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';
import 'package:malinrecetteflutter/ui/widget/buttons/primary_action_button_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? message;

  Future<void> login() async {
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await AuthService.saveToken(data['token']);
        await AuthService.saveUserData(data['user']);

        Navigator.of(context).pushReplacementNamed('/home_page');
      } else {
        setState(() {
          message = _errorFromResponse(response);
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        message = "Erreur réseau. Réessaie dans quelques instants.";
      });
    } finally {
      client.close();
    }
  }

  String _errorFromResponse(http.Response response) {
    // Si l'API renvoie un JSON avec "message", on le récupère
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] is String) {
        return body['message'] as String;
      }
    } catch (_) {
      // corps non-JSON (HTML 500) → on ignore
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      return "Email ou mot de passe incorrect.";
    }
    if (response.statusCode >= 500) {
      return "Le serveur rencontre un problème. Réessaie plus tard.";
    }
    return "Connexion impossible (code ${response.statusCode}).";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(height: 88),
      bottomNavigationBar: const FooterWidget(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Titre
                    Text(
                      'Connexion',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Content de te revoir !',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Champs
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    // Bouton de connexion
                    PrimaryActionButtonWidget(
                      label: "Se connecter",
                      onPressed: login,
                    ),
                    const SizedBox(height: 12),

                    // Lien inscription
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: const Text("Pas de compte ? S'inscrire !"),
                    ),

                    // Message d'erreur stylé
                    if (message != null && message!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
