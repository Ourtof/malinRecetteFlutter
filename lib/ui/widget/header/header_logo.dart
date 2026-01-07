import 'package:flutter/material.dart';

class HeaderLogo extends StatelessWidget {
  final double height;

  const HeaderLogo({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/home_page');
      },
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/img/logo_transparent.png',
        height: height * 0.9,
        fit: BoxFit.contain,
      ),
    );
  }
}

