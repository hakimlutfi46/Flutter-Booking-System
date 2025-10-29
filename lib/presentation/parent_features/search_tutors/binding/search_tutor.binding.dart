import 'package:flutter_booking_system/data/repository/parent_repository.dart';
import 'package:flutter_booking_system/presentation/parent_features/search_tutors/controller/search_tutor.controller.dart';
import 'package:get/get.dart';

class SearchTutorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentRepository>(() => ParentRepository());
    Get.lazyPut<SearchTutorController>(() => SearchTutorController());    
  }
}
