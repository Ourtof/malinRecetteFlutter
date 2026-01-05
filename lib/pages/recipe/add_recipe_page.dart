import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:malinrecetteflutter/repositories/recipe_repository.dart';
import 'package:malinrecetteflutter/ui/constants/app_colors.dart';
import 'package:malinrecetteflutter/ui/widget/buttons/primary_action_button_widget.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/utils/tag_helpers.dart';

class AddRecipePage extends StatefulWidget {
  final RecipeRepository recipeRepository;

  const AddRecipePage({super.key, required this.recipeRepository});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  bool _isLoadingTags = true;
  String? _tagsLoadError;
  List<String> _availableTags = [];
  final Set<String> _selectedTags = {};

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoadingTags = true;
      _tagsLoadError = null;
    });

    try {
      final tags = await widget.recipeRepository.fetchAvailableTags();
      setState(() {
        _availableTags = tags;
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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();

      setState(() {
        _pickedImage = image;
        _pickedImageBytes = bytes;
      });
    }
  }


  Future<void> _submit() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickedImageBytes == null || _pickedImage == null) {
      setState(() {
        _errorMessage = 'Une illustration est obligatoire pour la recette.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final titre = _titleController.text.trim();
    final contenu = _contentController.text.trim();

    try {
      final illustrationId = await widget.recipeRepository.uploadIllustration(
        _pickedImageBytes!,
        _pickedImage!.name,
      );

      await widget.recipeRepository.createRecipe(
        titre: titre,
        contenu: contenu,
        tagCodes: _selectedTags.toList(),
        illustrationId: illustrationId,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final objectifTags = _availableTags
        .where(TagHelpers.isObjectifTag)
        .toList(growable: false);
    final allergeneTags = _availableTags
        .where(TagHelpers.isAllergeneTag)
        .toList(growable: false);

    return Scaffold(
      appBar: const HeaderBar(height: 88),
      bottomNavigationBar: const FooterWidget(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Titre
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre de la recette',
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

                  // Contenu
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Contenu / étapes',
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

                  // Illustration
                  Text(
                    'Illustration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _pickedImageBytes == null
                            ? Container(
                                width: 64,
                                height: 64,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image_outlined,
                                  size: 28,
                                  color: Colors.grey,
                                ),
                              )
                            : Image.memory(
                                _pickedImageBytes!,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: _isSubmitting ? null : _pickImage,
                        icon: const Icon(Icons.upload_outlined, size: 18),
                        label: const Text(
                          'Choisir une image',
                          style: TextStyle(fontSize: 14),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tags
                  Text(
                    'Tags',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_isLoadingTags) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 16),
                  ] else if (_tagsLoadError != null) ...[
                    Text(
                      _tagsLoadError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    TextButton(
                      onPressed: _loadTags,
                      child: const Text('Recharger'),
                    ),
                    const SizedBox(height: 16),
                  ] else if (_availableTags.isEmpty) ...[
                    const Text(
                      'Aucun tag disponible pour le moment.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    if (objectifTags.isNotEmpty) ...[
                      Text(
                        'Objectif',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: objectifTags.map((tag) {
                          final isSelected = _selectedTags.contains(tag);
                          final label = TagHelpers.formatTagLabel(tag);
                          return FilterChip(
                            label: Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTags.add(tag);
                                } else {
                                  _selectedTags.remove(tag);
                                }
                              });
                            },
                            selectedColor: AppColors.neutral60.withOpacity(
                              0.18,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(color: AppColors.neutral60),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (allergeneTags.isNotEmpty) ...[
                      Text(
                        'Allergènes',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allergeneTags.map((tag) {
                          final isSelected = _selectedTags.contains(tag);
                          final label = TagHelpers.formatTagLabel(tag);
                          return FilterChip(
                            label: Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTags.add(tag);
                                } else {
                                  _selectedTags.remove(tag);
                                }
                              });
                            },
                            selectedColor: AppColors.neutral60.withOpacity(
                              0.18,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(color: AppColors.neutral60),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],

                  // Bouton centré, orange
                  Align(
                    alignment: Alignment.center,
                    child: PrimaryActionButtonWidget(
                      label: "Créer la recette",
                      onPressed:
                        _isSubmitting ? null : () => _submit(),
                    ),
                    /*child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neutral60,
                        textStyle: const TextStyle(fontSize: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Créer la recette'),
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
