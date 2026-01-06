import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/constants/food_profile_constants.dart';
import 'package:malinrecetteflutter/pages/profile/food_profile_edit_result.dart';

class FoodProfileDialog extends StatefulWidget {
  final String initialGoalType;
  final String initialDietType;
  final bool initialIsHalal;
  final Set<String> initialAllergies;
  final String initialOtherAllergies;

  const FoodProfileDialog({
    super.key,
    required this.initialGoalType,
    required this.initialDietType,
    required this.initialIsHalal,
    required this.initialAllergies,
    required this.initialOtherAllergies,
  });

  @override
  State<FoodProfileDialog> createState() => _FoodProfileDialogState();
}

class _FoodProfileDialogState extends State<FoodProfileDialog> {
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
              Navigator.of(context).pop<FoodProfileEditResult?>(null),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop<FoodProfileEditResult>(
              FoodProfileEditResult(
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

