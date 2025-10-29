import 'package:flutter/material.dart'; // Import biasa
import 'package:flutter_booking_system/core/navigation/routes.dart';
import 'package:flutter_booking_system/presentation/parent_features/search_tutors/controller/search_tutor.controller.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/presentation/widgets/info_card.dart';
import 'package:flutter_booking_system/presentation/widgets/loading_spinner.dart';

class SearchTutorScreen extends GetView<SearchTutorController> {
  const SearchTutorScreen({super.key}); // Perbaiki super.key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari Tutor"), // Tambah const
      ),
      body: Column(
        // Column sudah benar
        children: [
          // Search Bar (Kode ini sudah bagus)
          Padding(
            padding: const EdgeInsets.all(16.0), // Tambah const
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama atau subjek...',
                prefixIcon: const Icon(Icons.search), // Tambah const
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear), // Tambah const
                  onPressed: () {
                    controller.searchController.clear();
                    controller.filterTutors('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),

          // --- PERBAIKAN UTAMA DI SINI ---
          // 1. Gunakan Expanded agar ListView tahu batas tingginya
          Expanded(
            // 2. Obx membungkus bagian yang berubah (ListView)
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingSpinner();
              }
              // 3. Gunakan filteredTutors (sesuai controller baru)
              if (controller.filteredTutors.isEmpty) {
                return Center(
                  child: Text(
                    controller.searchController.text.isEmpty
                        ? "Belum ada tutor yang terdaftar."
                        : "Tutor tidak ditemukan.",
                  ),
                );
              }

              // 4. Tampilkan HASIL FILTER
              return ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                // 5. Gunakan filteredTutors (sesuai controller baru)
                itemCount: controller.filteredTutors.length,
                itemBuilder: (context, index) {
                  // 6. Gunakan filteredTutors (sesuai controller baru)
                  final tutor = controller.filteredTutors[index];
                  return InfoCard(
                    leadingIcon: Icons.person_outline,
                    title: tutor.name,
                    subtitle:
                        "Subjek: ${tutor.subject} | Rating: ${tutor.rating.toStringAsFixed(1)} ★",
                    trailing: const Icon(Icons.chevron_right), // Tambah const
                    onTap: () {
                      Get.toNamed(Routes.TUTOR_DETAIL, arguments: tutor.uid);
                    },
                  );
                },
              );
            }),
          ),
          // -----------------------------
        ],
      ),
    );
  }
}
