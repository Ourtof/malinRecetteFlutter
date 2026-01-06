import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/api/api_service.dart';
import 'package:malinrecetteflutter/config/api_config.dart';
import 'package:malinrecetteflutter/repositories/recipe_repository.dart';
import 'package:malinrecetteflutter/constants/app_colors.dart';
import 'package:malinrecetteflutter/ui/widget/buttons/primary_action_button_widget.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/utils/tag_helpers.dart';
import '../../models/recipe.dart';

class EditRecipePage extends StatefulWidget {
  final Recipe recipe;

  const EditRecipePage({super.key, required this.recipe});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  bool _isSaving = false;
  late final RecipeRepository _recipeRepository;

  // ---- TAGS (comme dans AddRecipePage) ----
  bool _isLoadingTags = true;
  String? _tagsLoadError;
  List<String> _availableTags = []; // même format que AddRecipe (Map.toString)
  final Set<String> _selectedTags = {}; // mêmes strings que _availableTags

  // Pour savoir quoi pré-sélectionner après chargement des tags
  late final Set<String> _initialTagContents;

  @override
  void initState() {
    super.initState();
    final apiService = ApiService(baseUrl: ApiConfig.baseUrl);
    _recipeRepository = RecipeRepository(apiService: apiService);
    
    _titleCtrl = TextEditingController(text: widget.recipe.titre);
    _contentCtrl = TextEditingController(text: widget.recipe.contenu);

    _initialTagContents = widget.recipe.tags
        .map((t) => t.contenu)
        .toSet(); // "Contient gluten"…

    _loadTags();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }


  Future<void> _loadTags() async {
    setState(() {
      _isLoadingTags = true;
      _tagsLoadError = null;
    });

    try {
      final tags = await _recipeRepository.fetchAvailableTags();

      // Pré-sélection des tags de la recette existante
      final selected = <String>{};
      for (final raw in tags) {
        final label = TagHelpers.formatTagLabel(raw);
        if (_initialTagContents.contains(label)) {
          selected.add(raw);
        }
      }

      setState(() {
        _availableTags = tags;
        _selectedTags
          ..clear()
          ..addAll(selected);
      });
    } catch (e) {
      setState(() {
        _tagsLoadError = 'Erreur lors du chargement des tags : $e';
      });
    } finally {
      setState(() {
        _isLoadingTags = false;
      });
    }
  }

  Widget _buildTagsSection(BuildContext context) {
    if (_isLoadingTags) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tagsLoadError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_tagsLoadError!, style: const TextStyle(color: Colors.red)),
          TextButton(
            onPressed: _loadTags,
            child: const Text('Recharger les tags'),
          ),
        ],
      );
    }

    if (_availableTags.isEmpty) {
      return const Text(
        'Aucun tag disponible pour le moment.',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }

    final objectifTags = _availableTags
        .where(TagHelpers.isObjectifTag)
        .toList(growable: false);
    final allergeneTags = _availableTags
        .where(TagHelpers.isAllergeneTag)
        .toList(growable: false);

    Wrap buildChips(List<String> source) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: source.map((raw) {
          final label = TagHelpers.formatTagLabel(raw);
          final isSelected = _selectedTags.contains(raw);
          return FilterChip(
            label: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedTags.add(raw);
                } else {
                  _selectedTags.remove(raw);
                }
              });
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            selectedColor: AppColors.neutral60.withOpacity(0.18),
            shape: StadiumBorder(
              side: BorderSide(
                color: AppColors.neutral60, // orange border
              ),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (objectifTags.isNotEmpty) ...[
          Text(
            'Objectif',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          buildChips(objectifTags),
          const SizedBox(height: 16),
        ],
        if (allergeneTags.isNotEmpty) ...[
          Text(
            'Allergènes',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          buildChips(allergeneTags),
        ],
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedRecipe = await _recipeRepository.updateRecipe(
        id: widget.recipe.id,
        titre: _titleCtrl.text.trim(),
        contenu: _contentCtrl.text.trim(),
        tagCodes: _selectedTags.toList(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(updatedRecipe);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const HeaderBar(height: 88),
      bottomNavigationBar: const FooterWidget(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Titre
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Titre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le titre est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contenu (multi-ligne, mais sans Expanded => plus de gros trou)
                  TextFormField(
                    controller: _contentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Contenu',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    minLines: 6,
                    maxLines: 12,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le contenu est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Tags
                  Text(
                    'Tags',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTagsSection(context),
                  const SizedBox(height: 24),

                  // Bouton Enregistrer
                  Align(
                    alignment: Alignment.center,
                    child: PrimaryActionButtonWidget(
                      label: 'Enregistrer',
                      onPressed: _isSaving ? null : _save,
                    ),
                    /*child: FilledButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _isSaving ? 'Enregistrement...' : 'Enregistrer',
                      ),
                    ),*/
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
