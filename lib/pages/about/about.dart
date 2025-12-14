import 'package:flutter/material.dart';
import 'package:malinrecetteflutter/ui/widget/header/header_bar.dart';
import 'package:malinrecetteflutter/ui/widget/footer/footer_widget.dart';

class About extends StatelessWidget {
  const About({super.key});

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
                  "À propos de Malin'Recette",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Une application de recettes pensée pour ton profil alimentaire.",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Divider(),

                _sectionTitle(theme, "1. Malin'Recette, c'est quoi ?"),
                _sectionBody(
                  "Malin'Recette est une application de recettes qui t’aide à trouver "
                  "rapidement des idées adaptées à ton profil alimentaire : objectifs "
                  "(sport, perte de poids, etc.), allergies et habitudes de vie.",
                ),

                _sectionTitle(theme, "2. Pour qui ?"),
                _sectionBody(
                  "Malin'Recette s'adresse principalement :\n"
                  "• À ceux qui veulent des recettes simples du quotidien.\n"
                  "• Aux personnes qui ont un objectif (sportif, minceur, etc.).\n"
                  "• À ceux qui doivent éviter certains allergènes (gluten, arachides, etc.).\n"
                  "• À tous ceux qui veulent gagner du temps sans passer 30 minutes à chercher une idée de repas.",
                ),

                _sectionTitle(theme, "3. Comment ça marche ?"),
                _sectionBody(
                  "1. Tu crées ton compte.\n"
                  "2. Tu renseignes ton profil alimentaire : objectif, type d’alimentation, allergies.\n"
                  "3. L’application filtre les recettes en fonction de ces informations.\n"
                  "4. Tu peux aussi ajouter tes propres recettes et les enrichir avec des tags.\n"
                  "5. Le système de recommandation te propose des recettes compatibles avec ton profil.",
                ),

                _sectionTitle(theme, "4. Qui sommes-nous ?"),
                _sectionBody(
                  "Malin'Recette est un projet développé par une petite équipe passionnée de "
                  "développement et d’alimentation du quotidien. C’est un projet en cours "
                  "d’évolution, conçu d’abord comme une application pratique, pas comme une vitrine marketing.",
                ),

                _sectionTitle(theme, "5. Notre philosophie"),
                _sectionBody(
                  "• Des recettes réalistes, faisables avec des ingrédients simples.\n"
                  "• Des filtres clairs : tu comprends pourquoi une recette t’est proposée.\n"
                  "• Pas de fonctionnalités obscures : l’objectif est de t’aider à manger mieux, pas de te piéger dans l’interface.\n"
                  "• Une évolution progressive de l’application, guidée par les retours des utilisateurs.",
                ),

                _sectionTitle(theme, "6. Limites et responsabilités"),
                _sectionBody(
                  "Les informations de l’application (tags \"healthy\", allergies, objectifs, etc.) "
                  "ont une valeur indicative. Elles ne remplacent pas l’avis d’un professionnel de santé.\n\n"
                  "En cas de pathologie, régime strict ou situation particulière, demande toujours "
                  "l’avis d’un médecin ou d’un nutritionniste avant de modifier ton alimentation.",
                ),

                _sectionTitle(theme, "7. Données personnelles"),
                _sectionBody(
                  "Les données que tu renseignes (profil alimentaire, recettes, préférences) sont utilisées "
                  "uniquement pour faire fonctionner l’application : affichage des recettes, filtres, "
                  "recommandations.\n\n"
                  "Pour plus de détails sur le traitement de tes données, tu peux consulter la page "
                  "« Mentions légales / CGU ».",
                ),

                _sectionTitle(theme, "8. Contact & retours"),
                _sectionBody(
                  "Tu as trouvé un bug, une incohérence dans une recette, ou tu veux proposer une nouvelle idée ?\n"
                  "Tu peux nous contacter via l’adresse e-mail indiquée dans les mentions légales ou via les "
                  "canaux prévus dans l’application.\n\n"
                  "Les retours constructifs sont les bienvenus : ils guident directement les prochaines évolutions.",
                ),

                _sectionTitle(theme, "9. Statut du projet"),
                _sectionBody(
                  "Malin'Recette est actuellement en version bêta. Certaines fonctionnalités peuvent encore "
                  "évoluer, être améliorées ou être retirées. L’application est amenée à changer au fil du temps "
                  "en fonction des tests et des retours utilisateurs.",
                ),

                const SizedBox(height: 32),
                Text(
                  "Cette page a pour but de t’expliquer clairement l’esprit de Malin'Recette et ce que tu peux en attendre au quotidien.",
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

// Helpers de mise en forme

Widget _sectionTitle(ThemeData theme, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _sectionBody(String text) {
  return Text(
    text,
    style: const TextStyle(height: 1.4),
  );
}
