import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/parent_features/my_bookings/controllers/my_bookings.controller.dart';
import 'package:get/get.dart';

class EmptyBookings extends StatelessWidget {
  final BookingStatusFilter status;
  const EmptyBookings({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String title, message;
    IconData icon;

    switch (status) {
      case BookingStatusFilter.upcoming:
        title = 'No Bookings Yet';
        message = 'You don’t have any upcoming sessions.';
        icon = Icons.event_note_outlined;
        break;
      case BookingStatusFilter.past:
        title = 'No History Yet';
        message = 'Your session history will appear here.';
        icon = Icons.history_edu_outlined;
        break;
      case BookingStatusFilter.cancelled:
        title = 'No Cancellations';
        message = 'You don’t have any cancelled sessions.';
        icon = Icons.event_busy_outlined;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
