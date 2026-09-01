import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/models/admin_user.dart';

void main() {
  test('fromJson parse un utilisateur complet', () {
    // Given
    final json = {
      'id': 1,
      'email': 'admin@test.fr',
      'pseudo': 'admin',
      'roles': ['ROLE_ADMIN', 'ROLE_USER'],
      'enabled': true,
    };

    // When
    final user = AdminUser.fromJson(json);

    // Then
    expect(user.id, 1);
    expect(user.email, 'admin@test.fr');
    expect(user.pseudo, 'admin');
    expect(user.roles, ['ROLE_ADMIN', 'ROLE_USER']);
    expect(user.enabled, isTrue);
  });

  test('fromJson applique les valeurs par défaut pour champs manquants', () {
    // Given
    final json = {'id': 2};

    // When
    final user = AdminUser.fromJson(json);

    // Then
    expect(user.email, '');
    expect(user.pseudo, '');
    expect(user.roles, isEmpty);
    expect(user.enabled, isFalse);
  });

  test('copyWith remplace uniquement les champs fournis', () {
    // Given
    const original = AdminUser(
      id: 1,
      email: 'a@test.fr',
      pseudo: 'user',
      roles: ['ROLE_USER'],
      enabled: true,
    );

    // When
    final updated = original.copyWith(enabled: false, pseudo: 'nouveau');

    // Then
    expect(updated.id, 1);
    expect(updated.email, 'a@test.fr');
    expect(updated.pseudo, 'nouveau');
    expect(updated.enabled, isFalse);
    expect(updated.roles, ['ROLE_USER']);
  });
}
