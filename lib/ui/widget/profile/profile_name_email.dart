import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class ProfileNameEmail extends StatelessWidget {
  final String pseudo;
  final String email;

  const ProfileNameEmail({
    super.key,
    required this.pseudo,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          pseudo.isNotEmpty ? pseudo : 'Utilisateur',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          email,
          style: const TextStyle(fontSize: 16, color: AppColors.neutral50),
        ),
      ],
    );
  }
}


