import 'package:flutter/material.dart';

// simplification verif mounted
extension MountedExtension on State {
  // évite les warnings
  bool get isMounted => mounted;

  // éxécute la fonction seulement si le widget est monté
  bool ifMounted(void Function() callback) {
    if (mounted) {
      callback();
      return true;
    }
    return false;
  }
}
