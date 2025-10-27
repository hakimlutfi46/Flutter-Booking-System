import 'package:flutter_booking_system/presentation/tutor_features/avability/controllers/avability.controller.dart';
import 'package:get/get.dart';

class AvabilityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AvabilityController>(() => AvabilityController());
  }
}