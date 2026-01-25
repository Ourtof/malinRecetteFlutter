import 'package:flutter/material.dart';

class AdminRecipeSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final Function(String) onSubmitted;

  const AdminRecipeSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onSubmitted,
  });

  @override
  State<AdminRecipeSearchBar> createState() => _AdminRecipeSearchBarState();
}

class _AdminRecipeSearchBarState extends State<AdminRecipeSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: 'Rechercher par titre, contenu ou auteur',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: widget.onClear,
              )
            : null,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onSubmitted: widget.onSubmitted,
    );
  }
}
