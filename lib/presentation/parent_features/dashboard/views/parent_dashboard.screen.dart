import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/parent_dashboard.controller.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';

class ParentDashboardScreen extends GetView<ParentDashboardController> {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authC = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        actions: [
          IconButton(
            onPressed: () => authC.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        // Tampilkan nama user dari firestoreUser
        child: Obx(
          () => Text(
            'Selamat datang, ${authC.firestoreUser.value?.name ?? authC.firestoreUser.value?.email}',
          ),
        ),
      ),
    );
  }
}
