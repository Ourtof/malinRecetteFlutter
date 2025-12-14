import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';

class MentionsLegales extends StatelessWidget {
  const MentionsLegales({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const HeaderBar(height: 88),
      bottomNavigationBar: const FooterWidget(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre principal
                Text(
                  "Conditions générales d'utilisation",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Dernière mise à jour : 6 mars 2025",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),

                _sectionTitle(theme, "1. Objet"),
                _sectionBody(
                  "Les présentes conditions générales d'utilisation (les « CGU ») "
                  "ont pour objet de définir les modalités et conditions dans "
                  "lesquelles l'utilisateur accède à l'application « Malin'Recette » "
                  "et utilise ses fonctionnalités.",
                ),

                _sectionTitle(theme, "2. Acceptation des CGU"),
                _sectionBody(
                  "En accédant à l'application ou en l'utilisant, l'utilisateur "
                  "reconnaît avoir pris connaissance des présentes CGU et les "
                  "accepter sans réserve. En cas de désaccord, l'utilisateur doit "
                  "cesser immédiatement toute utilisation de l'application.",
                ),

                _sectionTitle(theme, "3. Accès au service"),
                _sectionBody(
                  "L'application est accessible gratuitement (hors coûts de "
                  "connexion et d'équipement) 7j/7 et 24h/24, sous réserve des "
                  "opérations de maintenance, d'incidents techniques ou de cas de force majeure. "
                  "L'éditeur ne garantit pas l'absence d'interruptions ou de bugs.",
                ),

                _sectionTitle(theme, "4. Création de compte"),
                _sectionBody(
                  "Certaines fonctionnalités nécessitent la création d'un compte utilisateur. "
                  "L'utilisateur s'engage à fournir des informations exactes, complètes et à jour, "
                  "notamment concernant son adresse e-mail et ses préférences alimentaires. "
                  "L'utilisateur est seul responsable de la confidentialité de ses identifiants.",
                ),

                _sectionTitle(theme, "5. Utilisation de l'application"),
                _sectionBody(
                  "L'utilisateur s'engage à utiliser l'application de manière loyale et conforme "
                  "aux lois en vigueur, et notamment à ne pas :\n"
                  "• tenter d'accéder frauduleusement aux systèmes ou données d'autrui ;\n"
                  "• détourner l'application de sa finalité (recommandation et gestion de recettes) ;\n"
                  "• publier des contenus illicites, injurieux, haineux ou portant atteinte aux droits de tiers.",
                ),

                _sectionTitle(theme, "6. Contenus et propriété intellectuelle"),
                _sectionBody(
                  "L'ensemble des éléments présents sur l'application (textes, logos, interface, "
                  "charte graphique, etc.) est protégé par le droit de la propriété intellectuelle "
                  "et reste la propriété exclusive de l'éditeur ou de ses partenaires.\n\n"
                  "Toute reproduction, représentation, modification ou exploitation, totale ou "
                  "partielle, sans autorisation écrite préalable est strictement interdite.",
                ),

                _sectionTitle(theme, "7. Contenus créés par l'utilisateur"),
                _sectionBody(
                  "Lorsque l'utilisateur crée ou publie une recette, un avis ou tout autre contenu "
                  "dans l'application, il garantit :\n"
                  "• être titulaire des droits nécessaires sur ce contenu ;\n"
                  "• que ce contenu ne porte pas atteinte aux droits de tiers.\n\n"
                  "L'utilisateur autorise l'éditeur, à titre non exclusif et gratuit, à utiliser, "
                  "héberger, reproduire et diffuser ces contenus dans le cadre normal du service.",
                ),

                _sectionTitle(theme, "8. Données personnelles"),
                _sectionBody(
                  "Les données personnelles collectées dans le cadre de l'application (compte, "
                  "préférences alimentaires, logs de connexion, etc.) sont traitées conformément "
                  "à la législation en vigueur. Elles sont utilisées uniquement pour le "
                  "fonctionnement du service, l'amélioration des recommandations et, le cas échéant, "
                  "l'envoi de communications liées à l'application.\n\n"
                  "L'utilisateur dispose notamment d'un droit d'accès, de rectification et de "
                  "suppression de ses données, qu'il peut exercer en contactant l'éditeur via la "
                  "page de contact dédiée.",
                ),

                _sectionTitle(theme, "9. Responsabilités"),
                _sectionBody(
                  "Les informations et recommandations fournies par l'application (par exemple : "
                  "suggestions de recettes, filtres \"healthy\" ou \"allergènes\") ont une valeur "
                  "indicative. Elles ne remplacent pas l'avis d'un professionnel de santé ou d'un "
                  "nutritionniste.\n\n"
                  "L'éditeur ne saurait être tenu responsable :\n"
                  "• des conséquences liées à une mauvaise interprétation des informations ;\n"
                  "• des erreurs, omissions ou inexactitudes éventuelles ;\n"
                  "• de tout dommage résultant d'une utilisation non conforme de l'application.",
                ),

                _sectionTitle(theme, "10. Modification des CGU"),
                _sectionBody(
                  "L'éditeur se réserve le droit de modifier les présentes CGU à tout moment, afin "
                  "de les adapter aux évolutions de l'application, de la législation ou de ses "
                  "pratiques internes. La version en vigueur est celle publiée dans l'application "
                  "à la date de consultation. L'utilisation du service après modification vaut "
                  "acceptation des nouvelles CGU.",
                ),

                _sectionTitle(theme, "11. Durée et suppression du compte"),
                _sectionBody(
                  "Les présentes CGU sont conclues pour une durée indéterminée à compter de la "
                  "première utilisation de l'application.\n\n"
                  "L'utilisateur peut supprimer son compte à tout moment via l'interface prévue ou "
                  "sur demande auprès de l'éditeur. En cas de non-respect des présentes CGU, "
                  "l'éditeur se réserve le droit de suspendre ou de supprimer le compte utilisateur, "
                  "sans préavis ni indemnité.",
                ),

                _sectionTitle(
                  theme,
                  "12. Droit applicable et juridiction compétente",
                ),
                _sectionBody(
                  "Les présentes CGU sont soumises au droit français. En cas de litige relatif à "
                  "l'interprétation ou à l'exécution des CGU, et à défaut de résolution amiable, "
                  "les tribunaux français seront seuls compétents.",
                ),

                const SizedBox(height: 32),
                Text(
                  "Cette page est un modèle générique. Pense à la faire relire par un professionnel du droit "
                  "si tu l'utilises en production.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helpers de mise en forme (facultatif mais ça évite de répéter du code)

Widget _sectionTitle(ThemeData theme, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

Widget _sectionBody(String text) {
  return Text(text, style: const TextStyle(height: 1.4));
}
