import 'package:flutter/material.dart';

class RecipeFloatingButtons extends StatelessWidget {
  final bool isLogged;
  final bool isRecommending;
  final VoidCallback onRecommend;
  final VoidCallback onAdd;

  const RecipeFloatingButtons({
    super.key,
    required this.isLogged,
    required this.isRecommending,
    required this.onRecommend,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLogged) return const SizedBox.shrink();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: 'recommend_fab',
              onPressed: isRecommending ? null : onRecommend,
              label: const Text("Me proposer une recette"),
            ),
            FloatingActionButton(
              heroTag: 'add_fab',
              onPressed: onAdd,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

