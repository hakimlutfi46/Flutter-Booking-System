// lib/core/navigation/middleware/role_guard.dart
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';
import 'package:flutter_booking_system/core/navigation/routes.dart';
import 'package:get/get.dart';

class RoleGuard extends GetMiddleware {
  final List<String> allowedRoles; // Daftar peran yang diizinkan
  RoleGuard(this.allowedRoles);

  final authC = Get.find<AuthController>();

  // Jalan setelah AuthGuard (prio 1)
  @override
  int? get priority => 2;

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    // Kita 100% yakin 'AuthGuard' sudah memastikan
    // 'authC.firestoreUser.value' TIDAK null.

    final userRole = authC.firestoreUser.value!.role;

    if (allowedRoles.contains(userRole)) {
      // Peran diizinkan, lanjutkan.
      return await super.redirectDelegate(route);
    }

    // Peran tidak diizinkan! Tendang ke SPLASH.
    // (SPLASH akan otomatis redirect ke dashboard yang BENAR)
    return GetNavConfig.fromRoute(Routes.SPLASH);
  }
}
