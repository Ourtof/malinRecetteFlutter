import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService', () {
    test('isLoggedIn retourne false sans token', () async {
      expect(await AuthService.isLoggedIn(), isFalse);
    });

    test('saveToken et getToken stockent le JWT', () async {
      await AuthService.saveToken('mon-jwt-token');

      expect(await AuthService.getToken(), 'mon-jwt-token');
      expect(await AuthService.isLoggedIn(), isTrue);
    });

    test('saveRefreshToken et getRefreshToken', () async {
      await AuthService.saveRefreshToken('refresh-abc');

      expect(await AuthService.getRefreshToken(), 'refresh-abc');
    });

    test('saveUserData et isAdmin', () async {
      await AuthService.saveUserData({
        'id': 1,
        'email': 'admin@test.fr',
        'roles': ['ROLE_ADMIN', 'ROLE_USER'],
      });

      expect(await AuthService.isAdmin(), isTrue);
    });

    test('isAdmin retourne false pour un utilisateur standard', () async {
      await AuthService.saveUserData({
        'id': 2,
        'roles': ['ROLE_USER'],
      });

      expect(await AuthService.isAdmin(), isFalse);
    });

    test('logout supprime toutes les données', () async {
      await AuthService.saveToken('token');
      await AuthService.saveRefreshToken('refresh');
      await AuthService.saveUserData({'roles': ['ROLE_ADMIN']});

      await AuthService.logout();

      expect(await AuthService.getToken(), isNull);
      expect(await AuthService.getRefreshToken(), isNull);
      expect(await AuthService.isLoggedIn(), isFalse);
      expect(await AuthService.isAdmin(), isFalse);
    });
  });
}
