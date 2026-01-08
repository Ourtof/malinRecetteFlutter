import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:malinrecetteflutter/utils/form_validators.dart';

class EditProfileResult {
  final String prenom;
  final String nom;
  final String pseudo;
  final String email;
  final String password;
  final String adresse;
  final String ville;
  final String codePostal;

  EditProfileResult({
    required this.prenom,
    required this.nom,
    required this.pseudo,
    required this.email,
    required this.password,
    required this.adresse,
    required this.ville,
    required this.codePostal,
  });
}

Future<EditProfileResult?> showEditProfileDialog(
  BuildContext context, {
  required String initialPrenom,
  required String initialNom,
  required String initialPseudo,
  required String initialEmail,
  required String initialPassword,
  required String initialAdresse,
  required String initialVille,
  required String initialCodePostal,
}) {
  final formKey = GlobalKey<FormState>();
  final prenomController = TextEditingController(text: initialPrenom);
  final nomController = TextEditingController(text: initialNom);
  final pseudoController = TextEditingController(text: initialPseudo);
  final emailController = TextEditingController(text: initialEmail);
  final passwordController = TextEditingController(text: initialPassword);
  final adresseController = TextEditingController(text: initialAdresse);
  final villeController = TextEditingController(text: initialVille);
  final codePostalController = TextEditingController(text: initialCodePostal);

  return showDialog<EditProfileResult>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Modifier le profil'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: prenomController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Le prénom est requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Le nom est requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pseudoController,
                  decoration: const InputDecoration(labelText: 'Pseudo'),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Le pseudo est requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: adresseController,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: villeController,
                  decoration: const InputDecoration(labelText: 'Ville'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codePostalController,
                  decoration: const InputDecoration(labelText: 'Code postal'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: validateCodePostal,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) {
                return;
              }

              Navigator.of(context).pop(
                EditProfileResult(
                  prenom: prenomController.text.trim(),
                  nom: nomController.text.trim(),
                  pseudo: pseudoController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  adresse: adresseController.text.trim(),
                  ville: villeController.text.trim(),
                  codePostal: codePostalController.text.trim(),
                ),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      );
    },
  );
}
