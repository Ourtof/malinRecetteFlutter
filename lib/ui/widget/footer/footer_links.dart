import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/constants/app_colors.dart';
import 'package:malinrecetteflutter/ui/widget/navlink_widget.dart';

// widget pour les liens du footer
class FooterLinks extends StatelessWidget {
  final bool isMobile;

  const FooterLinks({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final links = [
      _FooterLink(
        label: 'Mentions légales',
        route: '/MentionsLegales',
      ),
      _FooterLink(
        label: 'Qui sommes-nous ?',
        route: '/about',
      ),
      _FooterLink(
        label: 'Contact',
        route: '/contact',
      ),
    ];

    if (isMobile) {
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: links.map((link) => _buildLink(context, link)).toList(),
      );
    }

    return Row(
      children: links
          .expand((link) => [
                _buildLink(context, link),
                const SizedBox(width: 16),
              ])
          .take(links.length * 2 - 1)
          .toList(),
    );
  }

  Widget _buildLink(BuildContext context, _FooterLink link) {
    return NavLink(
      label: link.label,
      textColor: AppColors.white,
      onTap: () {
        Navigator.of(context).pushNamed(link.route);
      },
    );
  }
}

class _FooterLink {
  final String label;
  final String route;

  _FooterLink({required this.label, required this.route});
}

