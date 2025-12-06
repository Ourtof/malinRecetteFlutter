import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/constants/app_colors.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import '../../../services/recipe_service.dart';

class AddRecipePage extends StatefulWidget {
  final RecipeService recipeService;

  const AddRecipePage({super.key, required this.recipeService});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  // ---- Gestion des tags existants ----
  bool _isLoadingTags = true;
  String? _tagsLoadError;
  List<String> _availableTags = [];
  final Set<String> _selectedTags = {};

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
      final tags = await widget.recipeService.fetchAvailableTags();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final titre = _titleController.text.trim();
    final contenu = _contentController.text.trim();
    final tags = _selectedTags.toList(); // <== ICI maintenant

    try {
      await widget.recipeService.createRecipe(
        titre: titre,
        contenu: contenu,
        tags: tags,
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
    return Scaffold(
      appBar: const HeaderBar(height: 88),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],

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

              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenu / étapes',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le contenu est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sélection des tags
              const Text(
                'Filtres',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
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
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              Center(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neutral60,
                    textStyle: TextStyle(fontSize: 16),
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
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FooterWidget(),
    );
  }
}
