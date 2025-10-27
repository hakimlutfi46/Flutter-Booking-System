// lib/core/navigation/middleware/auth_guard.dart
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';
import 'package:flutter_booking_system/core/navigation/routes.dart';
import 'package:get/get.dart';

class AuthGuard extends GetMiddleware {
  // Ambil AuthController yang sudah 'hidup'
  final authC = Get.find<AuthController>();

  // Beri prioritas agar jalan pertama
  @override
  int? get priority => 1;

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    // 1. Cek login Firebase Auth (user-nya ada?)
    if (authC.user == null) {
      // Jika tidak ada, tendang ke LOGIN
      return GetNavConfig.fromRoute(Routes.LOGIN);
    }

    // 2. Cek apakah data Firestore (role, nama) sudah di-load?
    if (authC.firestoreUser.value != null) {
      // Jika sudah, biarkan 'RoleGuard' (prio 2) yang bekerja
      return await super.redirectDelegate(route);
    }

    // 3. Jika belum di-load, panggil fungsi di AuthController
    try {
      // Kita 'tunggu' sampai data user dari Firestore selesai di-load
      await authC.loadFirestoreUser(authC.user!.uid);

      // Setelah data di-load, biarkan 'RoleGuard' lanjut
      return await super.redirectDelegate(route);
    } catch (e) {
      // Gagal load (misal user ada di Auth tapi tidak ada di Firestore)
      // Tendang ke LOGIN
      return GetNavConfig.fromRoute(Routes.LOGIN);
    }
  }
}
