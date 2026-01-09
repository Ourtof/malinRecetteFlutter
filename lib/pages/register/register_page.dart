import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:malinrecetteflutter/api/api_service_factory.dart';
import 'package:malinrecetteflutter/mixins/loading_mixin.dart';
import 'package:malinrecetteflutter/repositories/auth_repository.dart';
import 'package:malinrecetteflutter/utils/error_helpers.dart';
import 'package:malinrecetteflutter/utils/form_validators.dart';
import 'package:malinrecetteflutter/ui/widget/buttons/primary_action_button_widget.dart';
import 'package:malinrecetteflutter/ui/widget/error/error_message_card.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';

const _kSuccessMessage = "Inscription réussie !";

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with LoadingMixin {
  // Contrôleurs de formulaire
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final pseudoController = TextEditingController();
  final prenomController = TextEditingController();
  final nomController = TextEditingController();
  final adresseController = TextEditingController();
  final villeController = TextEditingController();
  final codePostalController = TextEditingController();

  String? successMessage;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(
      apiService: ApiServiceFactory.create(),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    pseudoController.dispose();
    prenomController.dispose();
    nomController.dispose();
    adresseController.dispose();
    villeController.dispose();
    codePostalController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (isLoading) return; // éviter les double clics
    
    if (!_formKey.currentState!.validate()) return;

    startLoading();

    try {
      await _authRepository.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        pseudo: pseudoController.text.trim(),
        prenom: prenomController.text.trim(),
        nom: nomController.text.trim(),
        adresse: adresseController.text.trim(),
        ville: villeController.text.trim(),
        codePostal: codePostalController.text.trim(),
      );

      if (!mounted) return;
      
      setState(() {
        successMessage = _kSuccessMessage;
        isLoading = false;
      });
      
      Navigator.of(context).pushReplacementNamed('/home_page');
    } catch (e) {
      setError(ErrorHelpers.extractErrorMessage(e));
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

                      _input(
                        emailController,
                        'Email',
                        keyboard: TextInputType.emailAddress,
                        validator: validateEmail,
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
                        validator: validateCodePostal,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushReplacementNamed('/login'),
                        child: const Text("Déjà un compte ? Se connecter !"),
                      ),

                      const SizedBox(height: 8),

                      PrimaryActionButtonWidget(
                        label: "S'inscrire",
                        onPressed: isLoading ? null : register,
                        isLoading: isLoading,
                      ),

                      // succès
                      if (successMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          successMessage!,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      // error
                      if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ErrorMessageCard(message: errorMessage!),
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
  String? Function(String?)? validator,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: validator ?? 
          ((value) => (value == null || value.isEmpty) ? "Champ requis" : null),
    ),
  );
}
