import 'package:flutter_booking_system/data/repository/booking_repository.dart';
import 'package:flutter_booking_system/presentation/parent_features/my_bookings/controllers/my_bookings.controller.dart';
import 'package:flutter_booking_system/presentation/shared_features/dashboard/controllers/dashboard.controller.dart';
import 'package:flutter_booking_system/presentation/shared_features/profile/controllers/profile.controller.dart';
import 'package:flutter_booking_system/presentation/tutor_features/avability/controllers/avability.controller.dart';
import 'package:get/get.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<AvabilityController>(() => AvabilityController());
    Get.lazyPut<MyBookingsController>(() => MyBookingsController());
    Get.put(BookingRepository());
  }
}
