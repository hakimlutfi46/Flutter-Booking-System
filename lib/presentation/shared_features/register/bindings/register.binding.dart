import 'package:flutter_booking_system/presentation/shared_features/register/controllers/register.controller.dart';
import 'package:get/get.dart';

class RegsiterBiding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}
