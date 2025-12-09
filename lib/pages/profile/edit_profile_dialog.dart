import 'package:flutter/material.dart';

class EditProfileResult {
  final String prenom;
  final String nom;
  final String pseudo;

  EditProfileResult({
    required this.prenom,
    required this.nom,
    required this.pseudo,
  });
}

Future<EditProfileResult?> showEditProfileDialog(
  BuildContext context, {
  required String initialPrenom,
  required String initialNom,
  required String initialPseudo,
}) {
  final prenomController = TextEditingController(text: initialPrenom);
  final nomController = TextEditingController(text: initialNom);
  final pseudoController = TextEditingController(text: initialPseudo);

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
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pseudoController,
                decoration: const InputDecoration(
                  labelText: 'Pseudo',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(
                EditProfileResult(
                  prenom: prenomController.text.trim(),
                  nom: nomController.text.trim(),
                  pseudo: pseudoController.text.trim(),
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
