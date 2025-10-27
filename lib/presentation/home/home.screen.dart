import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';

import 'package:get/get.dart';

import 'controllers/home.controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final AuthController authC = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeScreen'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => authC.logout(), 
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: Icon(Icons.add),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Selamat Datang!', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),

            // Tampilkan email user (gunakan Obx)
            Obx(() => Text(authC.user?.email ?? "Tidak ada data")),
          ],
        ),
      ),
    );
  }
}
