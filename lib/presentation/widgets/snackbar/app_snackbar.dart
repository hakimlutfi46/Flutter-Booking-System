import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Enum untuk tipe snackbar
enum SnackbarType { success, warning, error, neutral }

class AppSnackbar {
  static void show({
    required String title,
    required String message,
    required SnackbarType type,
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    // Tentukan warna berdasarkan tipe
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green.shade600;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case SnackbarType.warning:
        backgroundColor = Colors.orange.shade600;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case SnackbarType.error:
        backgroundColor = Colors.red.shade600;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case SnackbarType.neutral:
        backgroundColor = Colors.white;
        textColor = Colors.black87;
        icon = Icons.info_outline;
        break;
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: textColor,
      snackPosition: position,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(icon, color: textColor),
    );
  }
}
