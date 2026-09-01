import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/utils/date_formatter.dart';

void main() {
  test('formatDate retourne une chaîne vide pour null', () {
    // Given
    const DateTime? date = null;

    // When
    final result = DateFormatter.formatDate(date);

    // Then
    expect(result, '');
  });

  test('formatDate formate au format DD/MM/YYYY avec zéros de remplissage', () {
    // Given
    final dateAvecZeros = DateTime(2024, 3, 5);
    final dateSansZeros = DateTime(2024, 12, 25);

    // When
    final resultAvecZeros = DateFormatter.formatDate(dateAvecZeros);
    final resultSansZeros = DateFormatter.formatDate(dateSansZeros);

    // Then
    expect(resultAvecZeros, '05/03/2024');
    expect(resultSansZeros, '25/12/2024');
  });
}
