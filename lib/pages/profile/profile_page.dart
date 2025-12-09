import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:malinrecetteflutter/config/api_config.dart';
import 'package:malinrecetteflutter/pages/profile/edit_profile_dialog.dart';
import 'package:malinrecetteflutter/ui/constants/app_colors.dart';
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
                            Container(
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
                                backgroundImage: AssetImage(
                                  'assets/img/default_avatar.png',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user!['pseudo'] ?? 'Utilisateur',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user!['email'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 16,
                                ),
                                child: Column(
                                  children: [
                                    ProfileInformation(
                                      label: 'Prénom',
                                      value: user!['prenom'],
                                    ),
                                    ProfileInformation(
                                      label: 'Nom',
                                      value: user!['nom'],
                                    ),
                                    ProfileInformation(
                                      label: 'Pseudo',
                                      value: user!['pseudo'],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: _isUpdating
                                    ? null
                                    : () async {
                                        final result =
                                            await showEditProfileDialog(
                                          context,
                                          initialPrenom:
                                              user?['prenom'] ?? '',
                                          initialNom: user?['nom'] ?? '',
                                          initialPseudo:
                                              user?['pseudo'] ?? '',
                                        );

                                        if (result != null) {
                                          await _updateProfile(
                                            prenom: result.prenom,
                                            nom: result.nom,
                                            pseudo: result.pseudo,
                                          );
                                        }
                                      },
                                icon: _isUpdating
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.edit, size: 18),
                                label: const Text('Modifier le profil'),
                              ),
                            ),

                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: logout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.neutral60,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Se déconnecter',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: FooterWidget(),
    );
  }

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
          () => error =
              'Erreur : ${response.statusCode} — ${response.body}',
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
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/api/user'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(
              {'prenom': prenom, 'nom': nom, 'pseudo': pseudo},
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          user = jsonDecode(response.body);
          _isUpdating = false;
        });
      } else {
        setState(() {
          _isUpdating = false;
          error =
              'Erreur mise à jour : ${response.statusCode} — ${response.body}';
        });
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
