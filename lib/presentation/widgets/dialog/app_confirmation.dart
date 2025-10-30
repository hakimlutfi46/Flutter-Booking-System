import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';
import 'package:get/get.dart';

class AppConfirmation {
  /// Menampilkan dialog konfirmasi reusable
  static Future<bool> show({
    required String title,
    required String message,
    String confirmText = "Yes",
    String cancelText = "Cancel",
    Color? confirmColor,
    bool barrierDismissible = false,
    IconData? icon,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: confirmColor ?? Colors.blue),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText,
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );

    return result ?? false;
  }
}
