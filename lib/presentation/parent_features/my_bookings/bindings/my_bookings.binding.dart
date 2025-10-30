import 'package:flutter_booking_system/data/repository/tutor_repository.dart';
import 'package:flutter_booking_system/presentation/parent_features/my_bookings/controllers/my_bookings.controller.dart';
import 'package:get/get.dart';

class MyBookingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyBookingsController>(() => MyBookingsController());
    Get.lazyPut<TutorRepository>(() => TutorRepository());
  }
}
