import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/tutor_features/avability/controllers/avability.controller.dart';
import 'package:flutter_booking_system/presentation/widgets/add_slot_bootomsheet.dart';
import 'package:flutter_booking_system/presentation/widgets/schedule_list.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';
import 'package:flutter_booking_system/presentation/widgets/loading_spinner.dart';

class AvailabilityScreen extends GetView<AvabilityController> {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan DefaultTabController jika Anda mengelola tab di sini
    return DefaultTabController(
      length: 3, // Jumlah tab Anda
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          title: const Text(
            'Atur Jadwal Ketersediaan',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Container(
              color: AppColors.primary,
              child: const TabBar(
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    icon: Icon(Icons.event_note_outlined, size: 20),
                    text: 'Semua',
                  ),
                  Tab(
                    icon: Icon(Icons.event_available_outlined, size: 20),
                    text: 'Buka',
                  ),
                  Tab(
                    icon: Icon(Icons.event_busy_outlined, size: 20),
                    text: 'Penuh',
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          // Panggil fungsi bottom sheet dari file widget Anda
          onPressed: () => showAddSlotBottomSheet(context, controller),
          icon: const Icon(Icons.add),
          label: const Text('Tambah Jadwal'),
        ),

        // 1. BUNGKUS BODY DENGAN STACK
        body: Stack(
          children: [
            // 2. KONTEN UTAMA (TabBarView)
            Obx(() {
              // Loading awal (tetap sama)
              if (controller.isLoading.value &&
                  controller.availabilityList.isEmpty) {
                return const LoadingSpinner();
              }
              // Tampilkan TabBarView jika tidak loading atau list tidak kosong
              return const TabBarView(
                children: [
                  // Gunakan widget ScheduleList Anda
                  ScheduleList(filter: 'all'),
                  ScheduleList(filter: 'open'),
                  ScheduleList(filter: 'closed'),
                ],
              );
            }), // Akhir Obx konten utama
            // 3. TAMBAHKAN LOADING OVERLAY UNTUK HAPUS
            Obx(() {
              if (controller.isDeleting.value) {
                // Tampilkan overlay gelap semi-transparan
                return Container(
                  color: Colors.black.withOpacity(0.3),
                  // Tampilkan spinner di tengah
                  child: const LoadingSpinner(),
                );
              } else {
                // Jika tidak deleting, jangan tampilkan apa-apa
                return const SizedBox.shrink();
              }
            }), // Akhir Obx loading overlay
          ], // Children Stack
        ), // Akhir Stack
      ),
    );
  }
}
