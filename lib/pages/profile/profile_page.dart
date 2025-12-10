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

// --- Constantes communes profil alimentaire ---

const Map<String, String> kGoalTypeLabels = {
  'CLASSIQUE': 'Manger normalement',
  'SPORTIF': 'Prendre du muscle',
  'MINCEUR': 'Perdre du poids',
};

const Map<String, String> kDietTypeLabels = {
  'CLASSIQUE': 'Classique',
  'VEGETARIEN': 'Végétarien',
};

const Map<String, String> kAllergyLabels = {
  'GLUTEN': 'Gluten',
  'LAITAGE': 'Produits laitiers',
  'ARACHIDES': 'Arachides',
  'FRUITS_A_COQUE': 'Fruits à coque',
  'OEUF': 'Œuf',
  'SOJA': 'Soja',
  'POISSON': 'Poisson',
  'CRUSTACES': 'Crustacés',
};

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  String? error;
  bool _isUpdating = false;

  // ---- Profil alimentaire ----
  bool _isLoadingFoodProfile = true;
  String? _foodProfileError;
  bool _isSavingFoodProfile = false;

  String _goalType = 'CLASSIQUE';
  String _dietType = 'CLASSIQUE';
  bool _isHalal = false;
  Set<String> _allergies = {};
  final TextEditingController _otherAllergiesController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadFoodProfile();
  }

  @override
  void dispose() {
    _otherAllergiesController.dispose();
    super.dispose();
  }

  // Helpers pour affichage lisible
  String _goalTypeLabel() => kGoalTypeLabels[_goalType] ?? _goalType;
  String _dietTypeLabel() => kDietTypeLabels[_dietType] ?? _dietType;

  String _allergiesLabel() {
    if (_allergies.isEmpty && _otherAllergiesController.text.trim().isEmpty) {
      return 'Aucune';
    }

    final List<String> parts = [];

    if (_allergies.isNotEmpty) {
      parts.add(
        _allergies.map((code) => kAllergyLabels[code] ?? code).join(', '),
      );
    }

    final other = _otherAllergiesController.text.trim();
    if (other.isNotEmpty) {
      parts.add('Autres : $other');
    }

    return parts.join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(height: 100),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: error != null
            ? Center(
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              )
            : user == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
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
                          const SizedBox(height: 24),
                          _buildFoodProfileSummaryCard(),
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
      ),
      bottomNavigationBar: const FooterWidget(),
    );
  }

  // --- UI blocs existants ---

  Widget _buildAvatar() {
    // <= pas utilisé tant qu'on a pas fix l'avatar
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

  /// --- Nouvelle carte : résumé du profil alimentaire + bouton popup ---
  Widget _buildFoodProfileSummaryCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: _isLoadingFoodProfile
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profil alimentaire',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (_foodProfileError != null) ...[
                    Text(
                      _foodProfileError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                  ],

                  _buildSummaryRow('Objectif', _goalTypeLabel()),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Régime', _dietTypeLabel()),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Halal', _isHalal ? 'Oui' : 'Non'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Allergies', _allergiesLabel()),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _isLoadingFoodProfile
                          ? null
                          : _openFoodProfileDialog,
                      icon: const Icon(Icons.restaurant_menu, size: 18),
                      label: const Text('Modifier le profil alimentaire'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  Future<void> _openFoodProfileDialog() async {
    final result = await showDialog<_FoodProfileEditResult>(
      context: context,
      builder: (context) => _FoodProfileDialog(
        initialGoalType: _goalType,
        initialDietType: _dietType,
        initialIsHalal: _isHalal,
        initialAllergies: _allergies,
        initialOtherAllergies: _otherAllergiesController.text,
      ),
    );

    if (result == null) return;

    setState(() {
      _goalType = result.goalType;
      _dietType = result.dietType;
      _isHalal = result.isHalal;
      _allergies = result.allergies;
      _otherAllergiesController.text = result.otherAllergies;
    });

    await saveFoodProfile();
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

  Future<void> loadFoodProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() {
        _foodProfileError = 'Utilisateur non connecté.';
        _isLoadingFoodProfile = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/me/food-profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        setState(() {
          _goalType = (data['goalType'] as String?) ?? 'CLASSIQUE';
          _dietType = (data['dietType'] as String?) ?? 'CLASSIQUE';
          _isHalal = (data['isHalal'] as bool?) ?? false;

          final rawAllergies = (data['allergies'] as List?) ?? [];
          _allergies = rawAllergies.map((e) => e.toString()).toSet();

          _otherAllergiesController.text =
              (data['autreAllergies'] as String?) ?? '';

          _isLoadingFoodProfile = false;
          _foodProfileError = null;
        });
      } else {
        setState(() {
          _foodProfileError =
              'Erreur chargement profil alimentaire : ${response.statusCode}';
          _isLoadingFoodProfile = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _foodProfileError =
            'Erreur réseau lors du chargement du profil alimentaire : $e';
        _isLoadingFoodProfile = false;
      });
    }
  }

  Future<void> saveFoodProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() {
        _foodProfileError = 'Utilisateur non connecté.';
      });
      return;
    }

    setState(() {
      _isSavingFoodProfile = true;
      _foodProfileError = null;
    });

    final body = jsonEncode({
      'goalType': _goalType,
      'dietType': _dietType,
      'isHalal': _isHalal,
      'allergies': _allergies.toList(),
      'autreAllergies': _otherAllergiesController.text.trim().isEmpty
          ? null
          : _otherAllergiesController.text.trim(),
    });

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/me/food-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _isSavingFoodProfile = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil alimentaire mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isSavingFoodProfile = false;
          _foodProfileError =
              'Erreur sauvegarde profil alimentaire : ${response.statusCode}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_foodProfileError!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSavingFoodProfile = false;
        _foodProfileError =
            'Erreur réseau lors de la sauvegarde du profil alimentaire : $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_foodProfileError!),
          backgroundColor: Colors.red,
        ),
      );
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

class _FoodProfileEditResult {
  final String goalType;
  final String dietType;
  final bool isHalal;
  final Set<String> allergies;
  final String otherAllergies;

  _FoodProfileEditResult({
    required this.goalType,
    required this.dietType,
    required this.isHalal,
    required this.allergies,
    required this.otherAllergies,
  });
}

class _FoodProfileDialog extends StatefulWidget {
  final String initialGoalType;
  final String initialDietType;
  final bool initialIsHalal;
  final Set<String> initialAllergies;
  final String initialOtherAllergies;

  const _FoodProfileDialog({
    required this.initialGoalType,
    required this.initialDietType,
    required this.initialIsHalal,
    required this.initialAllergies,
    required this.initialOtherAllergies,
  });

  @override
  State<_FoodProfileDialog> createState() => _FoodProfileDialogState();
}

class _FoodProfileDialogState extends State<_FoodProfileDialog> {
  late String _goalType;
  late String _dietType;
  late bool _isHalal;
  late Set<String> _allergies;
  late TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    _goalType = widget.initialGoalType;
    _dietType = widget.initialDietType;
    _isHalal = widget.initialIsHalal;
    _allergies = {...widget.initialAllergies};
    _otherController = TextEditingController(
      text: widget.initialOtherAllergies,
    );
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le profil alimentaire'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Objectif
              DropdownButtonFormField<String>(
                value: _goalType,
                decoration: const InputDecoration(
                  labelText: 'Objectif',
                  border: OutlineInputBorder(),
                ),
                items: kGoalTypeLabels.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _goalType = value);
                },
              ),
              const SizedBox(height: 16),

              // Régime
              DropdownButtonFormField<String>(
                value: _dietType,
                decoration: const InputDecoration(
                  labelText: 'Régime',
                  border: OutlineInputBorder(),
                ),
                items: kDietTypeLabels.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _dietType = value);
                },
              ),
              const SizedBox(height: 16),

              // Halal
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Je souhaite manger halal'),
                value: _isHalal,
                onChanged: (value) {
                  setState(() => _isHalal = value);
                },
              ),
              const SizedBox(height: 12),

              // Allergies
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Allergies',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: kAllergyLabels.entries.map((entry) {
                  final code = entry.key;
                  final label = entry.value;
                  final selected = _allergies.contains(code);

                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(label),
                    value: selected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _allergies.add(code);
                        } else {
                          _allergies.remove(code);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Autres allergies
              TextField(
                controller: _otherController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Autres allergies (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop<_FoodProfileEditResult?>(null),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop<_FoodProfileEditResult>(
              _FoodProfileEditResult(
                goalType: _goalType,
                dietType: _dietType,
                isHalal: _isHalal,
                allergies: _allergies,
                otherAllergies: _otherController.text.trim(),
              ),
            );
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
