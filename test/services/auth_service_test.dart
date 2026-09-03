import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService', () {
    test('isLoggedIn retourne false sans token', () async {
      // Then
      expect(await AuthService.isLoggedIn(), isFalse);
    });

    test('saveToken et getToken stockent le JWT', () async {
      // When
      await AuthService.saveToken('mon-jwt-token');

      // Then
      expect(await AuthService.getToken(), 'mon-jwt-token');
      expect(await AuthService.isLoggedIn(), isTrue);
    });

    test('saveRefreshToken et getRefreshToken', () async {
      // When
      await AuthService.saveRefreshToken('refresh-abc');

      // Then
      expect(await AuthService.getRefreshToken(), 'refresh-abc');
    });

    test('saveUserData et isAdmin', () async {
      // Given
      final userData = {
        'id': 1,
        'email': 'admin@test.fr',
        'roles': ['ROLE_ADMIN', 'ROLE_USER'],
      };

      // When
      await AuthService.saveUserData(userData);

      // Then
      expect(await AuthService.isAdmin(), isTrue);
    });

    test('isAdmin retourne false pour un utilisateur standard', () async {
      // Given
      final userData = {
        'id': 2,
        'roles': ['ROLE_USER'],
      };

      // When
      await AuthService.saveUserData(userData);

      // Then
      expect(await AuthService.isAdmin(), isFalse);
    });

    test('logout supprime toutes les données', () async {
      // Given
      await AuthService.saveToken('token');
      await AuthService.saveRefreshToken('refresh');
      await AuthService.saveUserData({'roles': ['ROLE_ADMIN']});

      // When
      await AuthService.logout();

      // Then
      expect(await AuthService.getToken(), isNull);
      expect(await AuthService.getRefreshToken(), isNull);
      expect(await AuthService.isLoggedIn(), isFalse);
      expect(await AuthService.isAdmin(), isFalse);
    });
  });
}
