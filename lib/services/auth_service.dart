import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // vérifie si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Supprime le token (déconnexion)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Stocke un nouveau token JWT
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  // Vérifie si l'utilisateur a le rôle d'admin
  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return false;

    try {
      final Map<String, dynamic> user = jsonDecode(raw);
      final roles = user['roles'];

      if (roles is List) {
        return roles.contains('ROLE_ADMIN');
      }
    } catch (_) {
      return false;
    }

    return false;
  }
}
