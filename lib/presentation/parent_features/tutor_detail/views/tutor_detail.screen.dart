import 'package:flutter/material.dart';
import 'package:flutter_booking_system/data/models/avability_model.dart';
import 'package:flutter_booking_system/data/models/tutor_model.dart';
import 'package:flutter_booking_system/presentation/parent_features/tutor_detail/controller/tutor_detail.controller.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/presentation/widgets/loading_spinner.dart';
import 'package:flutter_booking_system/presentation/widgets/primary_button.dart';
import 'package:intl/intl.dart';

class TutorDetailScreen extends GetView<TutorDetailController> {
  const TutorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // 1. HAPUS floatingActionButton & floatingActionButtonLocation
      // floatingActionButton: Obx(...),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Obx(() {
        if (controller.isLoadingTutor.value) {
          return const LoadingSpinner();
        }

        if (controller.tutor.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  "Tutor tidak ditemukan",
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        final tutor = controller.tutor.value!;

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(tutor),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTutorInfoCard(tutor),
                  const SizedBox(height: 24),
                  _buildScheduleSection(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- Widget Helper ---

  Widget _buildSliverAppBar(TutorModel tutor) {
    // ... (Kode SliverAppBar tidak berubah)
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          tutor.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Get.theme.primaryColor,
                Get.theme.primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Hero(
              // Optional Hero animation
              tag: 'tutor_${tutor.uid}',
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  // Ambil inisial nama
                  tutor.name
                      .split(" ")
                      .take(2)
                      .map(
                        (word) => word.isNotEmpty ? word[0].toUpperCase() : '',
                      ) // Handle empty string case
                      .join(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorInfoCard(TutorModel tutor) {
    // ... (Kode Info Card tidak berubah)
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.school, size: 16, color: Get.theme.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      tutor.subject,
                      style: TextStyle(
                        color: Get.theme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade600, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    tutor.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    ' /5.0',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tentang Tutor',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tutor berpengalaman dengan spesialisasi ${tutor.subject}. Siap membantu Anda mencapai tujuan pembelajaran dengan metode yang efektif dan menyenangkan.', // Placeholder text
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Stats section (tidak berubah)
  Widget _buildStatsSection(TutorModel tutor) {
    // ... (Kode _buildStatsSection tidak berubah)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.schedule,
              label: 'Total Sesi',
              value: '24+', // Placeholder
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.people,
              label: 'Siswa',
              value: '15+', // Placeholder
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.verified,
              label: 'Pengalaman',
              value: '3 Tahun', // Placeholder
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Stat Card (tidak berubah)
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    // ... (Kode _buildStatCard tidak berubah)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Section Jadwal (tidak berubah)
  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.event_available,
                color: Get.theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Pilih Jadwal Tersedia',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildAvailabilityList(),
      ],
    );
  }

  // WIDGET LIST JADWAL (Tidak berubah fungsinya, hanya pemanggilan card)
  Widget _buildAvailabilityList() {
    return Obx(() {
      if (controller.isLoadingSlots.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: LoadingSpinner(),
        );
      }

      if (controller.availabilitySlots.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Jadwal',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tutor ini belum memiliki jadwal tersedia saat ini',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, height: 1.5),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.availabilitySlots.length,
        itemBuilder: (context, index) {
          final slot = controller.availabilitySlots[index];
          // Gunakan _buildScheduleCard baru yang lebih simpel
          return _buildScheduleCard(slot);
        },
      );
    });
  }

  // --- WIDGET KARTU JADWAL (PERUBAHAN BESAR DI SINI) ---
  Widget _buildScheduleCard(AvailabilityModel slot) {
    // Hapus parameter isSelected dan logikanya

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5, // Sedikit shadow
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(                
        onTap: () => controller.showBookingConfirmationDialog(slot),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ), // Padding lebih nyaman
          child: Row(
            children: [
              // Hapus AnimatedContainer (radio button custom)

              // Icon Waktu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.access_time_outlined,
                  color: Get.theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Detail Waktu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Format tanggal saja (misal: Sen, 28 Okt 2025)
                      DateFormat(
                        'EEE, d MMM yyyy',
                        'id_ID',
                      ).format(slot.startUTC.toLocal()),
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // Format jam saja (misal: 10:00 - 11:00)
                      "${DateFormat('HH:mm').format(slot.startUTC.toLocal())} - ${DateFormat('HH:mm').format(slot.endUTC.toLocal())}",
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron Icon (Indikator bisa diklik)
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Hapus widget _buildBookingFAB
  // Widget _buildBookingFAB() { ... }

  // Hapus helper _formatDate jika tidak dipakai lagi
  // String _formatDate(DateTime date) { ... }
}
