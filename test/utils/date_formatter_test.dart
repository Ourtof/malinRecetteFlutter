import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/utils/date_formatter.dart';

void main() {
  group('DateFormatter.formatDate', () {
    test('retourne une chaîne vide pour null', () {
      expect(DateFormatter.formatDate(null), '');
    });

    test('formate au format DD/MM/YYYY avec zéros de remplissage', () {
      expect(
        DateFormatter.formatDate(DateTime(2024, 3, 5)),
        '05/03/2024',
      );
      expect(
        DateFormatter.formatDate(DateTime(2024, 12, 25)),
        '25/12/2024',
      );
    });
  });
}
