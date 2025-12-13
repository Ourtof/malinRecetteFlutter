import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:malinrecetteflutter/config/api_config.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // -------- Helpers tags (reprise d’AddRecipePage) --------

  /// "{code: ARACHIDES, contenu: Contient arachides, categorie: ALLERGENE}"
  /// -> "Contient arachides"
  String _formatTagLabel(String raw) {
    if (!raw.contains('contenu:')) return raw;

    final contenuIndex = raw.indexOf('contenu:');
    if (contenuIndex == -1) return raw;

    final start = contenuIndex + 'contenu:'.length;
    final commaIndex = raw.indexOf(',', start);
    final end = commaIndex == -1 ? raw.length : commaIndex;

    return raw.substring(start, end).trim();
  }

  bool _isObjectifTag(String raw) =>
      raw.contains('categorie: OBJECTIF') || raw.contains('categorie:OBJECTIF');

  bool _isAllergeneTag(String raw) =>
      raw.contains('categorie: ALLERGENE') ||
      raw.contains('categorie:ALLERGENE');

  Future<void> _loadTags() async {
    setState(() {
      _isLoadingTags = true;
      _tagsLoadError = null;
    });

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/tags');
      final resp = await http.get(uri, headers: {'Accept': 'application/json'});

      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
      }

      final data = jsonDecode(resp.body) as List<dynamic>;
      final tags = data.map((e) => e.toString()).toList();

      // Pré-sélection des tags de la recette existante
      final selected = <String>{};
      for (final raw in tags) {
        final label = _formatTagLabel(raw);
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
        .where(_isObjectifTag)
        .toList(growable: false);
    final allergeneTags = _availableTags
        .where(_isAllergeneTag)
        .toList(growable: false);

    Wrap buildChips(List<String> source) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: source.map((raw) {
          final label = _formatTagLabel(raw);
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

    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token manquant, reconnecte-toi.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Extraction des codes depuis les strings sélectionnées
      final tagCodes = _selectedTags
          .map((raw) {
            final reg = RegExp(r'code:\s*([A-Z_]+)');
            final match = reg.firstMatch(raw);
            return match?.group(1);
          })
          .whereType<String>()
          .toList();

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/recettes/${widget.recipe.id}',
      );

      final body = jsonEncode({
        'titre': _titleCtrl.text.trim(),
        'contenu': _contentCtrl.text.trim(),
        'tagCodes': tagCodes,
      });

      final resp = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final updatedRecipe = Recipe.fromJson(data);

        if (!mounted) return;
        Navigator.of(context).pop(updatedRecipe);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour (${resp.statusCode})'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
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

                  Center(
                    child: FilledButton.icon(
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
                    ),
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
