import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/tutor_features/avability/controllers/avability.controller.dart';
import 'package:get/get.dart';
import 'availability_card.dart';
import 'empty_state.dart';

class ScheduleList extends GetView<AvabilityController> {
  final String filter;
  const ScheduleList({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filteredList =
          filter == 'all'
              ? controller.availabilityList
              : controller.availabilityList
                  .where((slot) => slot.status == filter)
                  .toList(); // ⚠️ ini masih perlu list, tapi dalam Obx jadi aman

      if (filteredList.isEmpty) {
        return EmptyState(filter: filter);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredList.length,
        itemBuilder: (_, index) {
          final slot = filteredList[index];
          return AvailabilityCard(slot: slot);
        },
      );
    });
  }
}
