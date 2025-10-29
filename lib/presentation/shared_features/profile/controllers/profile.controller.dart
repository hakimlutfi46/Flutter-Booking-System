import 'package:flutter/material.dart';
import 'package:flutter_booking_system/data/models/user_model.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';
import 'package:flutter_booking_system/presentation/widgets/dialog/app_confirmation.dart';
import 'package:flutter_booking_system/presentation/widgets/snackbar/app_snackbar.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Ambil AuthController global
  final AuthController authC = Get.find<AuthController>();

  // Expose data user untuk view (menggunakan getter)
  UserModel? get user => authC.firestoreUser.value;

  void logoutWithConfirmation() async {
    final confirmed = await AppConfirmation.show(
      title: "Konfirmasi Logout",
      message: "Apakah Anda yakin ingin keluar dari akun ini?",
      confirmText: "Logout",
      confirmColor: Colors.red,
      icon: Icons.logout,
    );

    if (!confirmed) return;

    // Kalau user menekan "Logout"
    authC.isLoading.value = true;
    try {
      await authC.logout();
      AppSnackbar.show(
        title: "Berhasil",
        message: "Anda telah keluar dari akun.",
        type: SnackbarType.success,
      );
    } catch (e) {
      AppSnackbar.show(
        title: "Gagal",
        message: "Gagal logout: ${e.toString()}",
        type: SnackbarType.error,
      );
    } finally {
      authC.isLoading.value = false;
    }
  }
}
