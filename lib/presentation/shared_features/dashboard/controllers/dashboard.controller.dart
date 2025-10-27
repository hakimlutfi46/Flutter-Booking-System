// lib/presentation/shared_features/dashboard/controllers/dashboard.controller.dart
import 'package:flutter_booking_system/core/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';

class DashboardController extends GetxController {
  final AuthController authC = Get.find<AuthController>();

  final Rxn<UserModel> user = Rxn<UserModel>();

  final isParent = false.obs;
  final isTutor = false.obs;

  var selectedIndex = 0.obs;

  String get userGreetingName => user.value?.name ?? 'Guest';

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();

    user.value = authC.firestoreUser.value;

    if (user.value != null) {
      isParent.value = user.value!.role == 'parent';
      isTutor.value = user.value!.role == 'tutor';
    }

    // Panggil fungsi untuk load data spesifik
    // loadRoleSpecificData();
  }

  void loadRoleSpecificData() {
    if (isParent.value) {
      print("Loading data untuk PARENT...");
    } else if (isTutor.value) {
      print("Loading data untuk TUTOR...");
    }
  }
}
