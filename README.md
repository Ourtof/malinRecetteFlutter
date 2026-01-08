# malinrecetteflutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## DEV

***** serveur *****

Démarrer le serveur en --no-tls pour pas que le serveur se démarre en https alors que dart cherche du http.

***** compte *****

compte user : azerty@gmail.com / azerty

compte admin : admin@gmail.com / admin

## SECURITE 

- Pour la sécurité, illustrations est limité par la taille ainsi que par le mime.

## ANECDOTE

- l'api m'a bien fait chier car crossOrigin obligatoire. Sinon, si ce n'était pas le cas, j'aurais pu enlever le show d'illustration et le faire en 2 lignes en flutter.
- Pour les type de personne, j'ai du faire un fichier Json car le front et le back sont deux technos séparées donc j'ai du me compliquer le projet là dessus aussi pour qu'ils communiquent.
- j'ai fait des fixtures pour les tags
- responsive : drawer et menu burger n'ont pas fonctionnés car il y a une interférence avec flutter web

ANECDOTE SECU :

Note sécurité : En production, remplacer allow_origin par une variable d'environnement dans le nelmio_cors

- rate_limiter : grosse sécurité, discussion chatgt pour plus d'info
d'ailleurs, package installé pour ça.
- dans UserController, j'ai sécurisé des données sensible comme adresse, role, code postal au cas ou, pour utilisateur et  admin.


RAF :
- gérer cas d'erreur quand on change de mail dans la page edit et qu'on met un mail déjà existant
- quand on change le mail d'un user, ce dernier n'est plus récupéré et ça crash quand on essaye de changer le profil alimentaire


1er audit sécurité : 
Score de sécurité global : 6.5/10
Points forts : protection SQL injection, hashage des mots de passe, JWT, protection path traversal.
Points faibles : CORS trop ouvert, pas de rate limiting, validation insuffisante, exposition de données.
Souhaitez-vous que je priorise et détaille les corrections à apporter ?