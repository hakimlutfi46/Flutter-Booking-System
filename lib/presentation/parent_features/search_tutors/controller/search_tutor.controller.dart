import 'package:flutter/material.dart'; // Import material untuk TextEditingController
import 'package:flutter_booking_system/data/models/tutor_model.dart';
import 'package:flutter_booking_system/data/repository/parent_repository.dart';
import 'package:get/get.dart';

class SearchTutorController extends GetxController {
  final ParentRepository _repository = ParentRepository();

  // Controller untuk search bar
  final TextEditingController searchController = TextEditingController();

  // Simpan daftar ASLI semua tutor (private)
  List<TutorModel> _allTutors = [];

  // Variabel RxList untuk menyimpan HASIL FILTER (yang akan ditampilkan)
  final RxList<TutorModel> filteredTutors = <TutorModel>[].obs;

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllTutors(); // Ambil data saat init

    // --- PERBAIKAN DEBOUNCE ---
    // Dengarkan perubahan pada searchController.text
    debounce(
      // Argumen pertama: Rx variable yang didengarkan (dalam hal ini, kita buat dari controller)
      RxString(searchController.text),
      // Argumen kedua: Fungsi callback yang menerima nilai baru
      (String query) => filterTutors(query),
      // Atur durasi debounce
      time: const Duration(milliseconds: 500),
    );
    // -------------------------

    // Tambahkan listener juga agar bisa update realtime saat user mengetik
    searchController.addListener(() {
      filterTutors(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAllTutors() async {
    try {
      isLoading.value = true;
      _allTutors = await _repository.getAllTutors();
      // Awalnya, tampilkan semua tutor di hasil filter
      filteredTutors.assignAll(_allTutors);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch tutors: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi filter (sudah benar, hanya pastikan menggunakan filteredTutors)
  void filterTutors(String query) {
    if (query.isEmpty) {
      filteredTutors.assignAll(_allTutors);
    } else {
      final lowerCaseQuery = query.toLowerCase();
      // Simpan hasil filter ke filteredTutors
      filteredTutors.value =
          _allTutors.where((tutor) {
            final nameMatch = tutor.name.toLowerCase().contains(lowerCaseQuery);
            final subjectMatch = tutor.subject.toLowerCase().contains(
              lowerCaseQuery,
            );
            return nameMatch || subjectMatch;
          }).toList();
    }
  }
}
