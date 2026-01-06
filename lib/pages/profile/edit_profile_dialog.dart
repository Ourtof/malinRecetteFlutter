import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/utils/snackbar_helpers.dart';

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pseudoController,
                decoration: const InputDecoration(labelText: 'Pseudo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adresseController,
                decoration: const InputDecoration(labelText: 'Adresse'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: villeController,
                decoration: const InputDecoration(labelText: 'Ville'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codePostalController,
                decoration: const InputDecoration(labelText: 'Code postal'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (prenomController.text.trim().isEmpty ||
                  nomController.text.trim().isEmpty ||
                  pseudoController.text.trim().isEmpty ||
                  emailController.text.trim().isEmpty) {
                SnackbarHelpers.showError(
                  context,
                  'Veuillez remplir tous les champs obligatoires',
                );
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
