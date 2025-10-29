import 'package:flutter/material.dart'; // Import material
import 'package:flutter_booking_system/data/models/booking_model.dart';
import 'package:flutter_booking_system/presentation/shared_features/dashboard/controllers/dashboard.controller.dart'; // Untuk sapaan
import 'package:flutter_booking_system/presentation/widgets/loading_spinner.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Import controller
import '../controllers/my_bookings.controller.dart'; // Pastikan path ini benar

class MyBookingsScreen extends GetView<MyBookingsController> {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Upcoming, Past, Cancelled
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: false,
                elevation: 1,
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
                expandedHeight: 120.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Get.theme.primaryColor,
                          Get.theme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'My Bookings',
                          style: Get.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  onTap: (index) {
                    final filter = BookingStatusFilter.values[index];
                    controller.changeTab(filter);
                  },
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.upcoming_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Upcoming'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Past'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cancel_presentation_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Cancelled'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          body: Obx(() {
            // Tampilkan loading HANYA saat data awal dimuat
            if (controller.isLoading.value) {
              return const LoadingSpinner();
            }
            // Tampilkan TabBarView setelah loading selesai
            return TabBarView(
              children: [
                _buildBookingList(BookingStatusFilter.upcoming),
                _buildBookingList(BookingStatusFilter.past),
                _buildBookingList(BookingStatusFilter.cancelled),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Widget untuk membangun daftar booking berdasarkan filter
  Widget _buildBookingList(BookingStatusFilter status) {
    return Obx(() {
      // Ambil SEMUA booking dari controller (via getter)
      final List<BookingModel> allBookings = controller.allbookings;

      // Lakukan FILTER di sini berdasarkan parameter 'status'
      final now = DateTime.now();
      final List<BookingModel> bookingsToShow;
      switch (status) {
        case BookingStatusFilter.upcoming:
          bookingsToShow =
              allBookings
                  .where(
                    (b) => b.status == 'confirmed' && b.startUTC.isAfter(now),
                  )
                  .toList();
          break;
        case BookingStatusFilter.past:
          bookingsToShow =
              allBookings
                  .where(
                    (b) => b.status != 'cancelled' && b.endUTC.isBefore(now),
                  )
                  .toList();
          break;
        case BookingStatusFilter.cancelled:
          bookingsToShow =
              allBookings.where((b) => b.status == 'cancelled').toList();
          break;
      }

      // Tampilkan empty state jika hasil filter kosong
      if (bookingsToShow.isEmpty) {
        return _buildEmptyState(status);
      }

      // Tampilkan ListView jika ada data
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: bookingsToShow.length,
        itemBuilder: (context, index) {
          final booking = bookingsToShow[index];
          final bool isUpcoming = status == BookingStatusFilter.upcoming;
          return _buildBookingCard(booking, isUpcoming);
        },
      );
    });
  }

  // --- Helper Widgets ---
  Widget _buildEmptyState(BookingStatusFilter status) {
    String title;
    String message;
    IconData icon;

    switch (status) {
      case BookingStatusFilter.upcoming:
        title = 'Belum Ada Booking';
        message = 'Anda belum memiliki sesi mendatang. Booking tutor sekarang!';
        icon = Icons.event_note_outlined;
        break;
      case BookingStatusFilter.past:
        title = 'Belum Ada Riwayat';
        message = 'Riwayat sesi Anda akan muncul di sini';
        icon = Icons.history_edu_outlined;
        break;
      case BookingStatusFilter.cancelled:
        title = 'Tidak Ada Pembatalan';
        message = 'Anda tidak memiliki sesi yang dibatalkan';
        icon = Icons.event_busy_outlined;
        break;
    }

    return Center(
      child: SingleChildScrollView(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking, bool isUpcoming) {
    final statusInfo = _getStatusInfo(booking.status);

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
          onTap: () => controller.viewBookingDetail(booking),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusInfo.color.withOpacity(0.15),
                            statusInfo.color.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        statusInfo.icon,
                        color: statusInfo.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // TODO: Ganti dengan nama Tutor asli
                            'Sesi dengan Tutor',
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID Tutor: ${booking.tutorId.substring(0, 8)}...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      child: Text(
                        statusInfo.label,
                        style: TextStyle(
                          color: statusInfo.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
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
                          Expanded(
                            child: Text(
                              _formatDate(booking.startUTC),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatTimeRange(
                                booking.startUTC,
                                booking.endUTC,
                              ),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isUpcoming &&
                    booking.status == 'confirmed' &&
                    booking.startUTC.isAfter(DateTime.now())) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              () => controller.cancelBooking(booking.uid),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Cancel'),
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
                          onPressed: () => controller.rebookBooking(booking),
                          icon: const Icon(Icons.replay_outlined, size: 18),
                          label: const Text('Rebook'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Get.theme.primaryColor,
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

  StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'confirmed':
        return StatusInfo(
          icon: Icons.check_circle_outline,
          label: 'CONFIRMED',
          color: Colors.green.shade600,
        );
      case 'cancelled':
        return StatusInfo(
          icon: Icons.cancel_outlined,
          label: 'CANCELLED',
          color: Colors.red.shade600,
        );
      case 'attended':
      case 'completed':
        return StatusInfo(
          icon: Icons.task_alt_outlined,
          label: 'COMPLETED',
          color: Colors.blue.shade600,
        );
      case 'noShow':
        return StatusInfo(
          icon: Icons.highlight_off,
          label: 'NO SHOW',
          color: Colors.orange.shade600,
        );
      default:
        return StatusInfo(
          icon: Icons.help_outline,
          label: 'UNKNOWN',
          color: Colors.grey.shade600,
        );
    }
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );
    if (dateToCheck == today) {
      return 'Hari Ini';
    } else if (dateToCheck == tomorrow) {
      return 'Besok';
    } else {
      return DateFormat('EEE, d MMM yyyy', 'id_ID').format(localDate);
    }
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${DateFormat('HH:mm').format(start.toLocal())} - ${DateFormat('HH:mm').format(end.toLocal())}';
  }
}

// Class StatusInfo (di luar MyBookingsScreen)
class StatusInfo {
  final IconData icon;
  final String label;
  final Color color;
  StatusInfo({required this.icon, required this.label, required this.color});
}
