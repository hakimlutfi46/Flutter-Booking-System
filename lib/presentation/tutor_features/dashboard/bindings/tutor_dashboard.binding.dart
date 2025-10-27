import 'package:flutter_booking_system/presentation/tutor_features/dashboard/controllers/tutor_dashboard.controller.dart';
import 'package:get/get.dart';

class TutorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TutorDashboardController>(() => TutorDashboardController());
  }
}
