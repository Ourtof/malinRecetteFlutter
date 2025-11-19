import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final pseudoController = TextEditingController();
  final prenomController = TextEditingController();
  final nomController = TextEditingController();
  final adresseController = TextEditingController();
  final villeController = TextEditingController();
  final codePostalController = TextEditingController();

  String? message;

  Future<void> register() async {
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse(
          'https://127.0.0.1:8000/api/register',
        ), //TODO: pareil que login pour l'ip
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
          'pseudo': pseudoController.text,
          'prenom': prenomController.text,
          'nom': nomController.text,
          'adresse': adresseController.text,
          'ville': villeController.text,
          'codePostal': codePostalController.text,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          message = "Inscription réussie !";
        });
        Navigator.of(context).pushReplacementNamed('/home_page');
      } else {
        setState(() {
          message = "Erreur : ${response.statusCode} - ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        message = "Erreur réseau : $e";
      });
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input(
                emailController,
                'Email',
                keyboard: TextInputType.emailAddress,
              ),
              _input(passwordController, 'Mot de passe', obscure: true),
              _input(pseudoController, 'Pseudo'),
              _input(prenomController, 'Prénom'),
              _input(nomController, 'Nom'),
              _input(adresseController, 'Adresse'),
              _input(villeController, 'Ville'),
              _input(
                codePostalController,
                'Code postal',
                keyboard: TextInputType.number,
              ),

              // Ajoutez d'autres champs ici...
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    register();
                  }
                },
                child: const Text("S'inscrire"),
              ),
              if (message != null) ...[
                const SizedBox(height: 20),
                Text(
                  message!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
              const SizedBox(height: 12),

              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text("Déjà un compte ? Se connecter !"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _input(
  TextEditingController c,
  String label, {
  bool obscure = false,
  TextInputType keyboard = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? "Champ requis" : null,
    ),
  );
}
