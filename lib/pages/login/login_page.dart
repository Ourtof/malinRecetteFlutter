import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/api/api_service_factory.dart';
import 'package:malinrecetteflutter/repositories/auth_repository.dart';
import 'package:malinrecetteflutter/utils/error_helpers.dart';
import 'package:malinrecetteflutter/ui/widget/buttons/primary_action_button_widget.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';

import '../../constants/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? message;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(
      apiService: ApiServiceFactory.create(),
    );
  }

  Future<void> login() async {
    try {
      await _authRepository.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;
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
                          color: AppColors.error.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 20,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message!,
                                style: const TextStyle(
                                  color: AppColors.error,
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
