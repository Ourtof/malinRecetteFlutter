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

compte user : user@test.fr / User!1122

compte admin : admin@test.fr / Admin!1122

## SECURITE 

- Pour la sécurité, illustrations est limité par la taille ainsi que par le mime.

Note : En production, remplacer allow_origin par une variable d'environnement dans le nelmio_cors

cf lexik_jwt_authentification.yaml.

## EN PROD

- remplacer allow_origin par une variable d'environnement dans le nelmio_cors

- faire passer tous les tests

- Améliorer le pipeline : automatiser l'envoie par FTP vers l'hébergement

## Test

- des tests créées avec phpUnit et flutter test

- apiService pas testable. http.get(), http.post() à remplacer par du http.Client.