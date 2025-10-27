// lib/presentation/shared_features/profile/controllers/profile.controller.dart
import 'package:flutter/material.dart'; // Untuk dialog
import 'package:flutter_booking_system/core/data/models/user_model.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';
import 'package:flutter_booking_system/presentation/widgets/primary_button.dart'; // Import tombol kita
import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Ambil AuthController global
  final AuthController authC = Get.find<AuthController>();

  // Expose data user untuk view (menggunakan getter)
  UserModel? get user => authC.firestoreUser.value;

  // Fungsi logout dengan konfirmasi
  void logoutWithConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          // Tombol Batal

          // Tombol Konfirmasi Logout
          // Kita pakai PrimaryButton agar ada loading indicator jika perlu
          TextButton(
            onPressed: () => Get.back(), // Tutup dialog
            child: const Text('Batal'),
          ),
          Obx(
            () => PrimaryButton(
              text: "Logout",
              isLoading:
                  authC.isLoading.value, // Gunakan status loading dari AuthC
              onPressed: () async {
                Get.back(); // Tutup dialog dulu
                await authC.logout(); // Panggil fungsi logout asli
              },
              // Sesuaikan style agar tidak full width di dialog
              // (Kita perlu modifikasi PrimaryButton atau buat tombol baru)
              // Untuk sementara, kita pakai ElevatedButton biasa
              // onPressed: () async {
              //   Get.back();
              //   await authC.logout();
              // },
            ),
          ),

          // Jika pakai ElevatedButton biasa:
          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          //   onPressed: () async {
          //     Get.back();
          //     await authC.logout();
          //   },
          //   child: const Text('Logout'),
          // )
        ],
      ),
      // Mencegah dialog ditutup dengan klik di luar area
      barrierDismissible: false,
    );
  }
}
