import 'package:flutter/material.dart';
import 'package:base_flutter/main.dart';

class Toast {
  static void show(String message) {
    ScaffoldMessengerState? messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      debugPrint("Toast: $message");
    }
  }
}
