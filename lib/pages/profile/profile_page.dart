import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/api/api_service_factory.dart';
import 'package:malinrecetteflutter/constants/food_profile_constants.dart';
import 'package:malinrecetteflutter/utils/error_helpers.dart';
import 'package:malinrecetteflutter/pages/profile/food_profile_dialog.dart';
import 'package:malinrecetteflutter/pages/profile/food_profile_edit_result.dart';
import 'package:malinrecetteflutter/repositories/user_repository.dart';
import 'package:malinrecetteflutter/repositories/admin_repository.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';
import 'package:malinrecetteflutter/ui/widget/buttons/primary_action_button_widget.dart';
import 'package:malinrecetteflutter/ui/widget/error/error_message_card.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/utils/snackbar_helpers.dart';
import 'package:malinrecetteflutter/ui/widget/profile/food_profile_summary_card.dart';
import 'package:malinrecetteflutter/ui/widget/profile/profile_name_email.dart';
import 'package:malinrecetteflutter/ui/widget/profile/profile_card.dart';
import 'package:malinrecetteflutter/ui/widget/profile/profile_edit_button.dart';

class ProfilePage extends StatefulWidget {
  final int? userId;

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  String? error;
  bool _isUpdating = false;
  late final UserRepository _userRepository;
  AdminRepository? _adminRepository;
  bool _isViewingOtherUser = false;

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
    
    if (widget.userId != null) {
      _isViewingOtherUser = true;
      _adminRepository = AdminRepository(
        apiService: ApiServiceFactory.create(),
      );
    }
    
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ErrorMessageCard(message: error!),
                ),
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
                          ProfileNameEmail(
                            pseudo: user!['pseudo'] ?? 'Utilisateur',
                            email: user!['email'],
                          ),
                          const SizedBox(height: 24),
                          ProfileCard(
                            prenom: user!['prenom'] ?? '',
                            nom: user!['nom'] ?? '',
                            pseudo: user!['pseudo'] ?? '',
                          ),
                          if (!_isViewingOtherUser) ...[
                            const SizedBox(height: 16),
                            ProfileEditButton(
                              isUpdating: _isUpdating,
                              user: user!,
                              onUpdate: (result) => _updateProfile(
                                prenom: result.prenom,
                                nom: result.nom,
                                pseudo: result.pseudo,
                                email: result.email,
                                adresse: result.adresse,
                                ville: result.ville,
                                codePostal: result.codePostal,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          FoodProfileSummaryCard(
                            isLoading: _isLoadingFoodProfile,
                            error: _foodProfileError,
                            goalTypeLabel: _goalTypeLabel(),
                            dietTypeLabel: _dietTypeLabel(),
                            isHalal: _isHalal,
                            allergiesLabel: _allergiesLabel(),
                            isSaving: _isSavingFoodProfile,
                            onEdit: _isViewingOtherUser ? null : _openFoodProfileDialog,
                          ),
                          if (!_isViewingOtherUser) ...[
                            const SizedBox(height: 32),
                            PrimaryActionButtonWidget(
                              label: 'Se déconnecter',
                              onPressed: logout,
                            ),
                            const SizedBox(height: 16),
                            PrimaryActionButtonWidget(
                              label: 'Supprimer le profil',
                              onPressed: _deleteProfile,
                            ),
                          ],
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
      Map<String, dynamic> profileData;
      
      if (_isViewingOtherUser && widget.userId != null && _adminRepository != null) {
        // Vérifier que l'utilisateur est admin
        final isAdmin = await AuthService.isAdmin();
        if (!isAdmin) {
          setState(() => error = 'Accès refusé. Seuls les administrateurs peuvent voir les profils des autres utilisateurs.');
          return;
        }
        
        profileData = await _adminRepository!.getUserProfile(widget.userId!);
      } else {
        profileData = await _userRepository.getProfile();
      }
      
      setState(() => user = profileData);
      
      // Si on charge le profil d'un autre utilisateur, extraire le profil alimentaire des données
      if (_isViewingOtherUser && profileData['foodProfile'] != null) {
        final foodProfileData = profileData['foodProfile'] as Map<String, dynamic>;
        setState(() {
          _goalType = (foodProfileData['goalType'] as String?) ?? 'CLASSIQUE';
          _dietType = (foodProfileData['dietType'] as String?) ?? 'CLASSIQUE';
          _isHalal = (foodProfileData['isHalal'] as bool?) ?? false;
          final rawAllergies = (foodProfileData['allergies'] as List?) ?? [];
          _allergies = rawAllergies.map((e) => e.toString()).toSet();
          _otherAllergiesController.text = (foodProfileData['autreAllergies'] as String?) ?? '';
          _isLoadingFoodProfile = false;
          _foodProfileError = null;
        });
      } else if (!_isViewingOtherUser) {
        // Charger le profil alimentaire normalement pour l'utilisateur connecté
        await loadFoodProfile();
      } else {
        // Pas de profil alimentaire pour l'utilisateur visualisé
        setState(() {
          _isLoadingFoodProfile = false;
          _foodProfileError = null;
        });
      }
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

      SnackbarHelpers.showSuccess(
        context,
        'Profil alimentaire mis à jour avec succès',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSavingFoodProfile = false;
        _foodProfileError =
            'Erreur réseau lors de la sauvegarde du profil alimentaire : $e';
      });

      SnackbarHelpers.showError(context, _foodProfileError!);
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

      SnackbarHelpers.showSuccess(context, 'Profil mis à jour avec succès');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUpdating = false;
        error = ErrorHelpers.extractErrorMessage(e);
      });

      SnackbarHelpers.showError(context, error!);
    }
  }

  Future<void> logout() async {
    await AuthService.logout();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _deleteProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le profil ?'),
        content: const Text(
          'Cette opération est définitive. Toutes tes données seront supprimées, '
          'y compris ton profil alimentaire et tes recettes. '
          'Es-tu sûr de vouloir supprimer ton profil ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _userRepository.deleteProfile();

      if (!mounted) return;

      // Déconnexion après suppression
      await AuthService.logout();

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      
      SnackbarHelpers.showInfo(context, 'Profil supprimé avec succès');
    } catch (e) {
      if (!mounted) return;
      SnackbarHelpers.showError(
        context,
        'Erreur : ${ErrorHelpers.extractErrorMessage(e)}',
      );
    }
  }
}
