import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/constants/app_colors.dart';
import 'package:malinrecetteflutter/pages/profile/edit_profile_dialog.dart';

class ProfileEditButton extends StatelessWidget {
  final bool isUpdating;
  final Map<String, dynamic> user;
  final Function({
    required String prenom,
    required String nom,
    required String pseudo,
    required String email,
    required String adresse,
    required String ville,
    required String codePostal,
  }) onUpdate;

  const ProfileEditButton({
    super.key,
    required this.isUpdating,
    required this.user,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: isUpdating
              ? null
              : () async {
                  final result = await showEditProfileDialog(
                    context,
                    initialPrenom: user['prenom'] ?? '',
                    initialNom: user['nom'] ?? '',
                    initialPseudo: user['pseudo'] ?? '',
                    initialEmail: user['email'] ?? '',
                    initialPassword: '',
                    initialAdresse: user['adresse'] ?? '',
                    initialVille: user['ville'] ?? '',
                    initialCodePostal: (user['codePostal']?.toString()) ?? '',
                  );

                  if (result != null) {
                    onUpdate(
                      prenom: result.prenom,
                      nom: result.nom,
                      pseudo: result.pseudo,
                      email: result.email,
                      adresse: result.adresse,
                      ville: result.ville,
                      codePostal: result.codePostal,
                    );
                  }
                },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            side: BorderSide(color: AppColors.neutral60),
          ),
          icon: isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.edit, size: 18, color: AppColors.neutral60),
          label: Text(
            'Modifier le profil',
            style: TextStyle(
              color: AppColors.neutral60,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

