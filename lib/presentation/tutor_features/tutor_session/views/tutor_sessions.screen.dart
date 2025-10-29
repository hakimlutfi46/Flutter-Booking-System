import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/tutor_features/tutor_session/controller/tutor_sessions.controller.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/data/models/booking_model.dart';
import 'package:flutter_booking_system/core/utils/formatter_utils.dart';
import 'package:flutter_booking_system/presentation/widgets/loading_spinner.dart';

class TutorSessionsScreen extends GetView<TutorSessionsController> {
  const TutorSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Get.theme.primaryColor,
        title: const Text(
          'Sesi Terjadwal',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        actions: [
          Obx(() {
            if (controller.isProcessing.value) {
              return const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingSpinner();
        }

        if (controller.upcomingSessions.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.upcomingSessions.length,
          itemBuilder: (context, index) {
            final session = controller.upcomingSessions[index];
            return _buildSessionCard(session);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Sesi Mendatang',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Slot yang Anda publikasikan akan muncul di sini setelah dipesan',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BookingModel session) {
    final statusInfo = _getStatusInfo(session.status);
    final isConfirmed = session.status == 'confirmed';

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.viewSessionDetail(session),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan waktu dan status badge
                Row(
                  children: [
                    // Time icon dengan background
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusInfo.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.access_time,
                        color: statusInfo.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Date and time info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FormatterUtils.formatDateRelative(session.startUTC),
                            style: TextStyle(
                              color: statusInfo.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${FormatterUtils.formatTimeOnly(session.startUTC)} - ${FormatterUtils.formatTimeOnly(session.endUTC)}',
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusInfo.color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusInfo.icon,
                            size: 14,
                            color: statusInfo.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusInfo.label,
                            style: TextStyle(
                              color: statusInfo.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Student info
                Row(
                  children: [
                    // Avatar dengan gradient
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          session.studentName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Student name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Siswa',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            session.studentName,
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Action buttons for confirmed sessions
                if (isConfirmed) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              () => controller.cancelSession(session.uid),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Batalkan'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              () => controller.completeSession(session.uid),
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                          ),
                          label: const Text('Selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
    
  SessionStatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'confirmed':
        return SessionStatusInfo(
          icon: Icons.schedule,
          label: 'TERJADWAL',
          color: Colors.blue.shade600,
        );
      case 'cancelled':
        return SessionStatusInfo(
          icon: Icons.cancel,
          label: 'DIBATALKAN',
          color: Colors.red.shade600,
        );
      case 'completed':
      case 'attended':
        return SessionStatusInfo(
          icon: Icons.check_circle,
          label: 'SELESAI',
          color: Colors.green.shade600,
        );
      case 'noShow':
        return SessionStatusInfo(
          icon: Icons.highlight_off,
          label: 'TIDAK HADIR',
          color: Colors.orange.shade600,
        );
      default:
        return SessionStatusInfo(
          icon: Icons.help_outline,
          label: 'UNKNOWN',
          color: Colors.grey.shade600,
        );
    }
  }
}

class SessionStatusInfo {
  final IconData icon;
  final String label;
  final Color color;

  SessionStatusInfo({
    required this.icon,
    required this.label,
    required this.color,
  });
}
