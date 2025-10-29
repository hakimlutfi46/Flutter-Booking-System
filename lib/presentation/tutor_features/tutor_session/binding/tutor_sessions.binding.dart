import 'package:flutter_booking_system/data/repository/tutor_session_repository.dart';
import 'package:flutter_booking_system/presentation/tutor_features/tutor_session/controller/tutor_sessions.controller.dart';
import 'package:get/get.dart';

class TutorSessionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TutorSessionsRepository>(() => TutorSessionsRepository());
    Get.lazyPut<TutorSessionsController>(() => TutorSessionsController());
  }
}
