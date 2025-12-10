// profile_page.dart APRES FREEZE

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:malinrecetteflutter/config/api_config.dart';
import 'package:malinrecetteflutter/pages/profile/edit_profile_dialog.dart';
import 'package:malinrecetteflutter/ui/constants/app_colors.dart';
import 'package:malinrecetteflutter/ui/widget/buttons/primary_action_button_widget.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/ui/widget/profile_information.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  String? error;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(height: 100),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: error != null
            ? Text(error!, style: const TextStyle(color: Colors.red))
            : user == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        //_buildAvatar(),
                        const SizedBox(height: 16),
                        _buildNameAndEmail(),
                        const SizedBox(height: 24),
                        _buildProfileCard(),
                        const SizedBox(height: 16),
                        _buildEditButton(),
                        const SizedBox(height: 32),
                        PrimaryActionButtonWidget(
                          label: 'Se déconnecter',
                          onPressed: logout,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: const FooterWidget(),
    );
  }

  Widget _buildAvatar() { // <= pas utilisé tant qu'on a pas fix l'avatar
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const CircleAvatar(
        radius: 45,
        backgroundImage: AssetImage('assets/img/default_avatar.png'),
      ),
    );
  }

  Widget _buildNameAndEmail() {
    return Column(
      children: [
        Text(
          user!['pseudo'] ?? 'Utilisateur',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          user!['email'],
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          children: [
            ProfileInformation(label: 'Prénom', value: user!['prenom']),
            ProfileInformation(label: 'Nom', value: user!['nom']),
            ProfileInformation(label: 'Pseudo', value: user!['pseudo']),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: _isUpdating
              ? null
              : () async {
                  final result = await showEditProfileDialog(
                    context,
                    initialPrenom: user?['prenom'] ?? '',
                    initialNom: user?['nom'] ?? '',
                    initialPseudo: user?['pseudo'] ?? '',
                    initialEmail: user?['email'] ?? '',
                    initialPassword: '',
                    initialAdresse: user?['adresse'] ?? '',
                    initialVille: user?['ville'] ?? '',
                    initialCodePostal: (user?['codePostal']?.toString()) ?? '',
                  );

                  if (result != null) {
                    await _updateProfile(
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
          icon: _isUpdating
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

  // --------- API ---------

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() => error = 'Utilisateur non connecté.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() => user = jsonDecode(response.body));
      } else {
        setState(
          () => error = 'Erreur : ${response.statusCode} — ${response.body}',
        );
      }
    } catch (e) {
      setState(() => error = 'Erreur réseau : $e');
    }
  }

  Future<void> _updateProfile({
    required String prenom,
    required String nom,
    required String pseudo,
    required String email,
    required String adresse,
    required String ville,
    required String codePostal,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() => error = 'Utilisateur non connecté.');
      return;
    }

    setState(() {
      _isUpdating = true;
      error = null;
    });

    try {
      final body = <String, dynamic>{
        'prenom': prenom,
        'nom': nom,
        'pseudo': pseudo,
        'email': email,
        'adresse': adresse,
        'ville': ville,
        'codePostal': codePostal,
      };

      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/api/user'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final updatedUser = jsonDecode(response.body);
        setState(() {
          user = updatedUser;
          _isUpdating = false;
        });

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isUpdating = false;
          error =
              'Erreur mise à jour : ${response.statusCode} — ${response.body}';
        });

        // Afficher l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error!), backgroundColor: Colors.red),
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isUpdating = false;
        error = 'Délai dépassé lors de la mise à jour du profil.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUpdating = false;
        error = 'Erreur réseau lors de la mise à jour : $e';
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
