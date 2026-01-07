import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/services/auth_service.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_logo.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_navigation_items.dart';
import 'package:malinrecetteflutter/utils/responsive_helpers.dart';

class HeaderContent extends StatefulWidget {
  final double height;
  const HeaderContent({super.key, required this.height});

  @override
  State<HeaderContent> createState() => _HeaderContentState();
}

class _HeaderContentState extends State<HeaderContent> {
  bool _isAdmin = false;
  bool _isLogged = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final isAdmin = await AuthService.isAdmin();
    final isLogged = await AuthService.isLoggedIn();
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
      _isLogged = isLogged;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelpers.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.0 : 24.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: isMobile ? 0 : 32,
            ),
            child: HeaderLogo(height: widget.height),
          ),
          HeaderNavigationItems(
            isMobile: isMobile,
            isAdmin: _isAdmin,
            isLogged: _isLogged,
          ),
        ],
      ),
    );
  }
}
