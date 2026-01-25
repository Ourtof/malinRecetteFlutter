import 'package:flutter/material.dart';

class AdminSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final Function(String) onSubmitted;
  final String labelText;

  const AdminSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onSubmitted,
    required this.labelText,
  });

  @override
  State<AdminSearchBar> createState() => _AdminSearchBarState();
}

class _AdminSearchBarState extends State<AdminSearchBar> {
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
        labelText: widget.labelText,
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
