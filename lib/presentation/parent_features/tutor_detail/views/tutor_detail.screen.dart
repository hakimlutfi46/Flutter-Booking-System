import 'package:flutter/material.dart';
import 'package:flutter_booking_system/data/models/tutor_model.dart';
import 'package:flutter_booking_system/presentation/parent_features/tutor_detail/controller/tutor_detail.controller.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/presentation/widgets/loading_spinner.dart';
import 'package:flutter_booking_system/presentation/widgets/primary_button.dart';

class TutorDetailScreen extends GetView<TutorDetailController> {
  const TutorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Judul AppBar menampilkan nama tutor (jika sudah loading)
        title: Obx(() => Text(controller.tutor.value?.name ?? 'Detail Tutor')),
      ),
      body: Obx(() {
        // Tampilkan loading utama jika data tutor belum ada
        if (controller.isLoadingTutor.value) {
          return const LoadingSpinner();
        }
        // Tampilan jika tutor tidak ditemukan
        if (controller.tutor.value == null) {
          return const Center(child: Text("Tutor tidak ditemukan."));
        }

        // Tampilan utama jika data tutor ada
        final tutor = controller.tutor.value!;
        return ListView(
          // Gunakan ListView agar bisa scroll
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Bagian Info Tutor ---
            _buildTutorInfoSection(tutor),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // --- Bagian Jadwal Tersedia ---
            Text(
              "Jadwal Tersedia",
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildAvailabilitySection(),

            // --- Tombol Booking (muncul jika slot dipilih) ---
            Obx(
              () =>
                  controller.selectedSlot.value == null
                      ? const SizedBox.shrink() // Sembunyikan jika tidak ada slot dipilih
                      : Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: PrimaryButton(
                          text: 'Konfirmasi Booking Pilihan Ini',
                          isLoading: controller.isBooking.value,
                          onPressed:
                              controller
                                  .processBooking, // Panggil fungsi booking
                        ),
                      ),
            ),
          ],
        );
      }),
    );
  }

  // --- Widget Helper untuk Info Tutor ---
  Widget _buildTutorInfoSection(TutorModel tutor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              // TODO: Tambahkan gambar profil tutor jika ada
              backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
              child: Text(
                tutor.name.substring(0, 1), // Inisial nama
                style: Get.textTheme.headlineMedium?.copyWith(
                  color: Get.theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutor.name,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Subjek: ${tutor.subject}",
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Tampilkan Rating
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  tutor.rating.toStringAsFixed(1),
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // (Tambahkan Bio atau info lain jika perlu)
      ],
    );
  }

  // --- Widget Helper untuk Daftar Jadwal ---
  Widget _buildAvailabilitySection() {
    return Obx(() {
      // Tampilkan loading jadwal
      if (controller.isLoadingSlots.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: LoadingSpinner(),
        );
      }
      // Tampilan jika tidak ada jadwal
      if (controller.availabilitySlots.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Center(
            child: Text("Tutor ini belum memiliki jadwal tersedia."),
          ),
        );
      }

      // Tampilkan daftar slot
      return ListView.builder(
        shrinkWrap: true, // Penting agar ListView di dalam ListView bisa jalan
        physics:
            const NeverScrollableScrollPhysics(), // Nonaktifkan scroll internal
        itemCount: controller.availabilitySlots.length,
        itemBuilder: (context, index) {
          final slot = controller.availabilitySlots[index];
          // Tandai slot yang sedang dipilih
          final isSelected = controller.selectedSlot.value?.uid == slot.uid;

          return Card(
            elevation: isSelected ? 4 : 1, // Beri efek shadow jika dipilih
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: isSelected ? Get.theme.primaryColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              title: Text(
                // Tampilkan waktu dalam format lokal
                controller.formatLocalTimeRange(slot.startUTC, slot.endUTC),
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              // Tombol radio untuk memilih
              leading: Radio<String>(
                value: slot.uid,
                groupValue: controller.selectedSlot.value?.uid,
                onChanged: (value) {
                  controller.selectSlot(
                    slot,
                  ); // Panggil fungsi select saat dipilih
                },
                activeColor: Get.theme.primaryColor,
              ),
              onTap:
                  () => controller.selectSlot(
                    slot,
                  ), // Bisa juga diklik di mana saja
            ),
          );
        },
      );
    });
  }
}
