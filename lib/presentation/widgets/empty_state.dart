import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyState extends StatelessWidget {
  final String filter;
  const EmptyState({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    String title, message;
    IconData icon;

    switch (filter) {
      case 'open':
        title = 'Tidak Ada Jadwal Buka';
        message = 'Semua jadwal Anda sudah terisi penuh.';
        icon = Icons.event_available_outlined;
        break;
      case 'closed':
        title = 'Tidak Ada Jadwal Penuh';
        message = 'Belum ada jadwal penuh.';
        icon = Icons.event_busy_outlined;
        break;
      default:
        title = 'Belum Ada Jadwal';
        message = 'Tambahkan jadwal untuk mulai menerima booking.';
        icon = Icons.event_note_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}
