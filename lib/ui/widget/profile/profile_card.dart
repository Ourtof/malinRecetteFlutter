import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/widget/profile_information.dart';

class ProfileCard extends StatelessWidget {
  final String prenom;
  final String nom;
  final String pseudo;

  const ProfileCard({
    super.key,
    required this.prenom,
    required this.nom,
    required this.pseudo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          children: [
            ProfileInformation(label: 'Prénom', value: prenom),
            ProfileInformation(label: 'Nom', value: nom),
            ProfileInformation(label: 'Pseudo', value: pseudo),
          ],
        ),
      ),
    );
  }
}


