import 'package:flutter_booking_system/presentation/parent_features/my_bookings/controllers/my_bookings.controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MyBookingsScreen extends GetView<MyBookingsController> {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Center(child: Text("My Bookings")));
  }
}
