import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/tutor_features/avability/controllers/avability.controller.dart';
import 'package:get/get.dart';

class AvabilityScreen extends GetView<AvabilityController> {
  const AvabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Center(child: Text("Avability")));
  }
}
