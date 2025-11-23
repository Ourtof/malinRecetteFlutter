import 'package:flutter/material.dart';

class ProfileInformation extends StatelessWidget {
  final String label;
  final String? value;
  const ProfileInformation({super.key, required this.label, this.value});

  Widget _profileRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value ?? '-', style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _profileRow(label, value);
  }
}
