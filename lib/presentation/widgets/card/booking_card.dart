import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/utils/formatter_utils.dart';
import 'package:flutter_booking_system/core/utils/status_info.dart';
import 'package:flutter_booking_system/presentation/parent_features/my_bookings/controllers/my_bookings.controller.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/data/models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isUpcoming;
  final MyBookingsController controller;

  const BookingCard({
    super.key,
    required this.booking,
    required this.isUpcoming,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = StatusInfo.fromStatus(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.viewBookingDetail(booking),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(statusInfo),
              const SizedBox(height: 20),
              _buildTimeInfo(),
              if (isUpcoming && booking.status == 'confirmed')
                _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StatusInfo info) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              info.color.withOpacity(0.15),
              info.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(info.icon, color: info.color, size: 24),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sesi dengan Tutor',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            Text(
              'ID Tutor: ${booking.tutorId.substring(0, 8)}...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
      _buildStatusChip(info),
    ],
  );

  Widget _buildStatusChip(StatusInfo info) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: info.color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: info.color.withOpacity(0.3)),
    ),
    child: Text(
      info.label,
      style: TextStyle(
        color: info.color,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    ),
  );

  Widget _buildTimeInfo() => Row(
    children: [
      Expanded(
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              FormatterUtils.formatDateRelative(booking.startUTC),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      Spacer(),
      Expanded(
        child: Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              FormatterUtils.formatTimeRange(booking.startUTC, booking.endUTC),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildActionButtons() => Column(
    children: [
      const Divider(height: 24),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => controller.cancelBooking(booking.uid),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                side: BorderSide(color: Colors.red.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.rebookBooking(booking),
              icon: const Icon(Icons.replay_outlined, size: 18),
              label: const Text('Rebook'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
