import 'package:flutter_booking_system/data/repository/booking_repository.dart';
import 'package:flutter_booking_system/data/repository/parent_repository.dart';
import 'package:flutter_booking_system/presentation/parent_features/tutor_detail/controller/tutor_detail.controller.dart';
import 'package:get/get.dart';

class TutorDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentRepository>(() => ParentRepository());
    Get.lazyPut<BookingRepository>(() => BookingRepository());
    Get.lazyPut<TutorDetailController>(() => TutorDetailController());
  }
}
