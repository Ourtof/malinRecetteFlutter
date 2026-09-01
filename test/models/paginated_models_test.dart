import 'package:flutter_test/flutter_test.dart';
import 'package:malinrecetteflutter/models/paginated_recipes.dart';
import 'package:malinrecetteflutter/models/paginated_users.dart';
import 'package:malinrecetteflutter/models/paginated_admin_recipes.dart';

void main() {
  test('PaginatedRecipes.fromJson parse une page de recettes', () {
    // Given
    final json = {
      'items': [
        {
          'id': 1,
          'titre': 'Soupe',
          'contenu': 'Chaude',
        },
      ],
      'total': 1,
      'page': 1,
      'limit': 10,
    };

    // When
    final result = PaginatedRecipes.fromJson(json);

    // Then
    expect(result.items, hasLength(1));
    expect(result.items.first.titre, 'Soupe');
    expect(result.total, 1);
    expect(result.page, 1);
    expect(result.limit, 10);
  });

  test('PaginatedRecipes.fromJson retourne une liste vide si items absent', () {
    // Given
    final json = {
      'items': null,
      'total': 0,
      'page': 1,
      'limit': 10,
    };

    // When
    final result = PaginatedRecipes.fromJson(json);

    // Then
    expect(result.items, isEmpty);
  });

  test('PaginatedUsers.fromJson parse une page d\'utilisateurs', () {
    // Given
    final json = {
      'items': [
        {
          'id': 1,
          'email': 'u@test.fr',
          'pseudo': 'user1',
          'roles': ['ROLE_USER'],
          'enabled': true,
        },
      ],
      'total': 42,
      'page': 2,
      'limit': 20,
    };

    // When
    final result = PaginatedUsers.fromJson(json);

    // Then
    expect(result.items, hasLength(1));
    expect(result.items.first.email, 'u@test.fr');
    expect(result.total, 42);
    expect(result.page, 2);
  });

  test('PaginatedAdminRecipes.fromJson parse une page de recettes admin', () {
    // Given
    final json = {
      'items': [
        {
          'id': 7,
          'titre': 'Risotto',
          'contenu': 'Crémeux',
        },
      ],
      'total': 7,
      'page': 1,
      'limit': 20,
    };

    // When
    final result = PaginatedAdminRecipes.fromJson(json);

    // Then
    expect(result.items, hasLength(1));
    expect(result.items.first.titre, 'Risotto');
    expect(result.total, 7);
  });
}
