import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/api/api_service_factory.dart';
import 'package:malinrecetteflutter/repositories/auth_repository.dart';
import 'package:malinrecetteflutter/utils/error_helpers.dart';
import 'package:malinrecetteflutter/ui/widget/buttons/primary_action_button_widget.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';

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
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(
      apiService: ApiServiceFactory.create(),
    );
  }

  Future<void> register() async {
    try {
      await _authRepository.register(
        email: emailController.text,
        password: passwordController.text,
        pseudo: pseudoController.text,
        prenom: prenomController.text,
        nom: nomController.text,
        adresse: adresseController.text,
        ville: villeController.text,
        codePostal: codePostalController.text,
      );

      if (!mounted) return;
      setState(() {
        message = "Inscription réussie !";
      });
      Navigator.of(context).pushReplacementNamed('/home_page');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        message = ErrorHelpers.extractErrorMessage(e);
      });
    }
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
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Titre
                      Text(
                        "Créer un compte",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Rejoins Malin Recette pour une expérience plus personnalisée.",
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Champs
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

                      const SizedBox(height: 16),

                      // Lien "Déjà un compte ? Se connecter !"
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushReplacementNamed('/login'),
                        child: const Text("Déjà un compte ? Se connecter !"),
                      ),

                      const SizedBox(height: 8),

                      // Bouton principal "S'inscrire"
                      PrimaryActionButtonWidget(
                        label: "S'inscrire",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            register();
                          }
                        },
                      ),

                      // Message éventuel
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
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
