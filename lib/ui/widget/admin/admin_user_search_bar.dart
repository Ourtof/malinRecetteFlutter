import 'package:flutter/material.dart';

class AdminUserSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final Function(String) onSubmitted;

  const AdminUserSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onSubmitted,
  });

  @override
  State<AdminUserSearchBar> createState() => _AdminUserSearchBarState();
}

class _AdminUserSearchBarState extends State<AdminUserSearchBar> {
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
        labelText: 'Rechercher par pseudo ou email',
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

