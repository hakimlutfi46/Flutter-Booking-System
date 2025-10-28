import 'package:flutter_booking_system/core/data/models/avability_model.dart';
import 'package:flutter_booking_system/core/data/repository/tutor_repository.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AvabilityController extends GetxController {
  // Instance dependencies
  final AuthController authC = Get.find<AuthController>();
  // 1. GANTI FIRESTORE LANGSUNG dengan REPOSITORY
  final TutorRepository _repository = TutorRepository();
  final Uuid _uuid = const Uuid(); // Untuk membuat ID unik

  // State List untuk jadwal
  final RxList<AvailabilityModel> availabilityList = <AvailabilityModel>[].obs;

  // State input UI
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  Rx<TimeOfDay?> endTime = Rx<TimeOfDay?>(null);

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 2. Mulai stream saat controller dibuat
    fetchAvailabilityStream();
  }

  // --- READ (Membaca Jadwal Real-Time) ---
  void fetchAvailabilityStream() {
    final tutorId = authC.user?.uid;
    if (tutorId == null) return;

    // Gunakan Stream dari Repository
    _repository
        .getTutorAvailabilityStream(tutorId)
        .listen((data) {
          // Data sudah berupa List<AvailabilityModel>
          availabilityList.value = data;
        })
        .onError((error) {
          Get.snackbar("Error", "Gagal memuat jadwal: ${error.toString()}");
        });
  }

  // --- CREATE (Membuat Slot Baru) ---
  Future<void> addSlot() async {
    if (selectedDate.value == null ||
        startTime.value == null ||
        endTime.value == null) {
      Get.snackbar("Perhatian", "Semua kolom tanggal dan waktu harus diisi!");
      return;
    }

    isLoading.value = true;
    try {
      final tutorId = authC.user!.uid;
      final selectedDay = selectedDate.value!;

      // 3. LOGIKA KONVERSI WAKTU (SANGAT PENTING!)
      final startLocal = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        startTime.value!.hour,
        startTime.value!.minute,
      );
      final endLocal = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        endTime.value!.hour,
        endTime.value!.minute,
      );

      final startUTC = startLocal.toUtc();
      final endUTC = endLocal.toUtc();

      if (endUTC.isBefore(startUTC) || endUTC.isAtSameMomentAs(startUTC)) {
        Get.snackbar("Gagal", "Waktu selesai harus setelah waktu mulai.");
        return;
      }

      // 4. BUAT INSTANCE MODEL BARU
      final newSlot = AvailabilityModel(
        uid: _uuid.v4(), // Buat ID unik dengan UUID
        tutorId: tutorId,
        startUTC: startUTC,
        endUTC: endUTC,
        capacity: 1,
        status: 'open',
      );

      // 5. KIRIM KE REPOSITORY
      await _repository.createAvailabilitySlot(newSlot);

      Get.snackbar(
        "Sukses!",
        "Slot jadwal berhasil ditambahkan.",
        backgroundColor: AppColors.primary,
        colorText: AppColors.background,
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal menambahkan slot: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // --- DELETE (Menghapus Slot) ---
  Future<void> removeSlot(String slotId) async {
    try {
      await _repository.deleteAvailabilitySlot(slotId);
      Get.snackbar("Berhasil", "Slot dihapus.");
    } catch (e) {
      Get.snackbar("Gagal", "Gagal menghapus slot: ${e.toString()}");
    }
  }

  // Helper untuk menampilkan waktu lokal (sudah benar)
  String formatLocalTime(DateTime utcTime) {
    // Pastikan kamu sudah install package intl
    final localTime = utcTime.toLocal();
    return DateFormat('EEE, d MMM yyyy HH:mm').format(localTime);
  }
}
