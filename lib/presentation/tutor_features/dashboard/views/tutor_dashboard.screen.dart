import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/tutor_features/dashboard/controllers/tutor_dashboard.controller.dart';
import 'package:get/get.dart';
// Import AuthController-mu untuk logout
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';

class TutorDashboardScreen extends GetView<TutorDashboardController> {
  const TutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authC = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor Dashboard'),
        actions: [
          IconButton(
            onPressed: () => authC.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Obx(
          () => Text(
            'Selamat datang, ${authC.firestoreUser.value?.name ?? authC.firestoreUser.value?.email}',
          ),
        ),
      ),
    );
  }
}
