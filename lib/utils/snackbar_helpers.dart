import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Helpers pour Snackbar
class SnackbarHelpers {
  // SnackBar de succès (vert)
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // error snackbar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: message.contains('\n')
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.split('\n').first,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...message
                      .split('\n')
                      .skip(1)
                      .map((line) => Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 4),
                            child: Text(
                              line,
                              style: const TextStyle(fontSize: 13),
                            ),
                          )),
                ],
              )
            : Text(message),
        backgroundColor: AppColors.error,
        duration: message.contains('\n') 
            ? const Duration(seconds: 6) 
            : const Duration(seconds: 4),
      ),
    );
  }

  // SnackBar d'information (par défaut)
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}


