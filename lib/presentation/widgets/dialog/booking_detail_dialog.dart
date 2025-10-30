import 'package:flutter/material.dart';
import 'package:flutter_booking_system/data/models/booking_model.dart';
import 'package:flutter_booking_system/core/utils/status_info.dart';
import 'package:flutter_booking_system/data/models/tutor_model.dart';
import 'package:get/get.dart';

class BookingDetailDialog extends StatelessWidget {
  final BookingModel booking;
  final String formattedTime;
  final TutorModel? tutor;

  const BookingDetailDialog({
    super.key,
    required this.booking,
    required this.formattedTime,
    this.tutor,
  });

  // Static method untuk menampilkan dialog
  static void show(BookingModel booking, String formattedTime) {
    Get.dialog(
      BookingDetailDialog(booking: booking, formattedTime: formattedTime),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = StatusInfo.fromStatus(booking.status);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan icon
            _buildHeader(),

            const SizedBox(height: 24),

            // Status badge
            _buildStatusBadge(statusInfo),

            const SizedBox(height: 24),

            // Detail items
            _buildDetailRow(Icons.person_outline, 'Siswa', booking.studentName),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.school_outlined,
              'Tutor',
              tutor != null
                  ? tutor!.name
                  : 'ID: ${booking.tutorId.substring(0, 12)}...',
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.access_time, 'Waktu Sesi', formattedTime),

            const SizedBox(height: 24),

            // Close button
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Get.theme.primaryColor.withOpacity(0.8),
                Get.theme.primaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_long, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Booking',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 2),
              Text(
                'ID: ${booking.uid.substring(0, 8)}...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(StatusInfo statusInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusInfo.color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.icon, size: 18, color: statusInfo.color),
          const SizedBox(width: 8),
          Text(
            statusInfo.label,
            style: TextStyle(
              color: statusInfo.color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: Get.back,
        style: ElevatedButton.styleFrom(
          backgroundColor: Get.theme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Tutup',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
