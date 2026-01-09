import 'package:flutter/material.dart';

// mixin pour gérer l'état de chargement et les erreurs dans les pages
mixin LoadingMixin<T extends StatefulWidget> on State<T> {
  bool isLoading = false;
  String? errorMessage;

  // démarre le chargement et efface les erreurs précédentes
  void startLoading() {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }
  }

  // arrête le chargement
  void stopLoading() {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // définit un message d'erreur et arrête le chargement
  void setError(String? message) {
    if (mounted) {
      setState(() {
        errorMessage = message;
        isLoading = false;
      });
    }
  }

  // efface le message d'erreur
  void clearError() {
    if (mounted) {
      setState(() {
        errorMessage = null;
      });
    }
  }
}
