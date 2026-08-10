import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/ui/widget/error/error_message_card.dart';

void main() {
  testWidgets('ErrorMessageCard affiche le message simple', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorMessageCard(message: 'Email invalide'),
        ),
      ),
    );

    expect(find.text('Email invalide'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('ErrorMessageCard affiche titre et détails sur plusieurs lignes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorMessageCard(
            message: 'Mot de passe invalide :\n• Trop court\n• Pas de chiffre',
          ),
        ),
      ),
    );

    expect(find.text('Mot de passe invalide :'), findsOneWidget);
    expect(find.text('• Trop court'), findsOneWidget);
    expect(find.text('• Pas de chiffre'), findsOneWidget);
  });
}
