class FoodProfileEditResult {
  final String goalType;
  final String dietType;
  final bool isHalal;
  final Set<String> allergies;
  final String otherAllergies;

  FoodProfileEditResult({
    required this.goalType,
    required this.dietType,
    required this.isHalal,
    required this.allergies,
    required this.otherAllergies,
  });
}

