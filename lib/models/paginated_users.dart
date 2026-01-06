import 'package:malinrecetteflutter/models/admin_user.dart';

class PaginatedUsers {
  final List<AdminUser> items;
  final int total;
  final int page;
  final int limit;

  PaginatedUsers({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaginatedUsers.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return PaginatedUsers(
      items: itemsJson
          .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
    );
  }
}


