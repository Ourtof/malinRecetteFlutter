## DEV

***** serveur *****

Démarrer le serveur en --no-tls pour pas que le serveur se démarre en https alors que dart cherche du http.

***** compte *****

compte user : user@test.fr / User!1122

compte admin : admin@test.fr / Admin!1122

## SECURITE 

- Pour la sécurité, illustrations est limité par la taille ainsi que par le mime.

Note : En production, remplacer allow_origin par une variable d'environnement dans le nelmio_cors

cf lexik_jwt_authentification.yaml.

## EN PROD

- remplacer allow_origin par une variable d'environnement dans le nelmio_cors

- Améliorer le pipeline : automatiser l'envoie par FTP vers l'hébergement

## Test

- des tests créées avec phpUnit et flutter test et phpUnit.

- apiService pas testable. http.get(), http.post() à remplacer par du http.Client.

## CI/CD

Pipeline GitHub Actions sur la branche dev :

- tests : exécute flutter test.
- preparation-deploiement (job "tests" requis) : build `flutter build web --release` et publie l'artifact `malinrecette-frontend`.

## DÉPLOIEMENT

- Le contenu de la compilation du build n'est pas pris en charge par le pipeline.
- Amélioration possible : automatiser cet envoi par FTP dans le pipeline (non implémenté ici, argumenté dans le dossier de projet).