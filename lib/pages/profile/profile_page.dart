import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/api/api_service_factory.dart';
import 'package:malinrecetteflutter/constants/food_profile_constants.dart';
import 'package:malinrecetteflutter/utils/error_helpers.dart';
import 'package:malinrecetteflutter/pages/profile/edit_profile_dialog.dart';
import 'package:malinrecetteflutter/pages/profile/food_profile_dialog.dart';
import 'package:malinrecetteflutter/pages/profile/food_profile_edit_result.dart';
import 'package:malinrecetteflutter/repositories/user_repository.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';
import 'package:malinrecetteflutter/constants/app_colors.dart';
import 'package:malinrecetteflutter/ui/widget/buttons/primary_action_button_widget.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/ui/widget/profile_information.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  String? error;
  bool _isUpdating = false;
  late final UserRepository _userRepository;

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
    _userRepository = UserRepository(
      apiService: ApiServiceFactory.create(),
    );
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
                      onPressed: (_isLoadingFoodProfile || _isSavingFoodProfile)
                          ? null
                          : _openFoodProfileDialog,
                      icon: _isSavingFoodProfile
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restaurant_menu, size: 18),
                      label: Text(
                        _isSavingFoodProfile
                            ? 'Enregistrement...'
                            : 'Modifier le profil alimentaire',
                      ),
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
    final result = await showDialog<FoodProfileEditResult>(
      context: context,
      builder: (context) => FoodProfileDialog(
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
    try {
      final profileData = await _userRepository.getProfile();
      setState(() => user = profileData);
    } catch (e) {
      setState(() => error = ErrorHelpers.extractErrorMessage(e));
    }
  }

  Future<void> loadFoodProfile() async {
    try {
      final data = await _userRepository.getFoodProfile();

      if (!mounted) return;

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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _foodProfileError = ErrorHelpers.extractErrorMessage(e);
        _isLoadingFoodProfile = false;
      });
    }
  }

  Future<void> saveFoodProfile() async {
    setState(() {
      _isSavingFoodProfile = true;
      _foodProfileError = null;
    });

    try {
      await _userRepository.updateFoodProfile(
        goalType: _goalType,
        dietType: _dietType,
        isHalal: _isHalal,
        allergies: _allergies,
        otherAllergies: _otherAllergiesController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isSavingFoodProfile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil alimentaire mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
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
    setState(() {
      _isUpdating = true;
      error = null;
    });

    try {
      final updatedUser = await _userRepository.updateProfile(
        prenom: prenom,
        nom: nom,
        pseudo: pseudo,
        email: email,
        password: password,
        adresse: adresse,
        ville: ville,
        codePostal: codePostal,
      );

      if (!mounted) return;

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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUpdating = false;
        error = ErrorHelpers.extractErrorMessage(e);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error!), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> logout() async {
    await AuthService.logout();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
