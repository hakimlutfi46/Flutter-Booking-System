import 'package:flutter_booking_system/presentation/shared_features/splash/controller/splash.controller.dart';
import 'package:get/get.dart';

class SplashControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
