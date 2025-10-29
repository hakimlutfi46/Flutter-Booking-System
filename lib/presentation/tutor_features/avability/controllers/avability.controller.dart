import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_booking_system/data/models/avability_model.dart';
import 'package:flutter_booking_system/data/repository/tutor_repository.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';
import 'package:uuid/uuid.dart';

class AvabilityController extends GetxController {
  final AuthController authC = Get.find<AuthController>();
  final TutorRepository _repository = TutorRepository();
  final Uuid _uuid = const Uuid();

  // RxList untuk jadwal
  final RxList<AvailabilityModel> availabilityList = <AvailabilityModel>[].obs;

  // State input UI
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  Rx<TimeOfDay?> endTime = Rx<TimeOfDay?>(null);

  final isLoading = false.obs; // Digunakan untuk addSlot
  final isDeleting = false.obs;

  // Variabel untuk menyimpan StreamSubscription
  StreamSubscription<List<AvailabilityModel>>? _availabilitySubscription;

  @override
  void onInit() {
    super.onInit();
    ever(authC.firebaseUser, _handleAuthChangesForStream);
    _handleAuthChangesForStream(authC.user);
  }

  @override
  void onClose() {
    _cancelAvailabilityStream();
    super.onClose();
  }

  void _handleAuthChangesForStream(User? firebaseUser) {
    _cancelAvailabilityStream();
    if (firebaseUser != null && authC.firestoreUser.value?.role == 'tutor') {
      fetchAvailabilityStream(firebaseUser.uid);
    } else {
      availabilityList.clear();
    }
  }

  void _cancelAvailabilityStream() {
    _availabilitySubscription?.cancel();
    _availabilitySubscription = null;
  }

  // --- READ (Stream Firestore) ---
  void fetchAvailabilityStream(String tutorId) {
    _cancelAvailabilityStream();
    _availabilitySubscription = _repository
        .getTutorAvailabilityStream(tutorId)
        .listen(
          (data) => availabilityList.assignAll(data),
          onError: (error) {
            if (authC.firestoreUser.value?.role == 'tutor') {
              Get.snackbar("Error", "Gagal memuat jadwal: ${error.toString()}");
            }
            print("Firestore Stream Error: $error");
          },
        );
  }

  // --- CREATE (Tambah Slot) ---
  Future<void> addSlot() async {
    // ... (kode addSlot tidak berubah) ...
    if (selectedDate.value == null ||
        startTime.value == null ||
        endTime.value == null) {
      Get.snackbar("Perhatian", "Semua kolom tanggal dan waktu harus diisi!");
      return;
    }

    final tutorId = authC.user?.uid;
    if (tutorId == null) {
      Get.snackbar("Error", "Sesi Anda telah berakhir. Silakan login kembali.");
      return;
    }

    isLoading.value = true;
    try {
      final selectedDay = selectedDate.value!;
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
        isLoading.value = false; // Hentikan loading jika validasi gagal
        return;
      }

      final newSlot = AvailabilityModel(
        uid: _uuid.v4(), // Buat ID unik dengan UUID
        tutorId: tutorId,
        startUTC: startUTC,
        endUTC: endUTC,
        capacity: 1, // Eksplisit tambahkan capacity
        status: 'open',
      );

      await _repository.createAvailabilitySlot(tutorId, newSlot);

      Get.snackbar(
        "Sukses!",
        "Slot jadwal berhasil ditambahkan.",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      resetForm(); // Reset form setelah sukses

      await Future.delayed(const Duration(milliseconds: 1500));
      if (Get.isBottomSheetOpen ?? false) Get.back();
    } catch (e) {
      Get.snackbar("Error", "Gagal menambahkan slot: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // --- DELETE (Hapus Slot) ---
  Future<void> removeSlot(String slotId) async {
    final tutorId = authC.user?.uid;
    if (tutorId == null) {
      Get.snackbar("Error", "Sesi Anda telah berakhir.");
      throw Exception("User not logged in"); // Lempar error agar bisa ditangkap
    }
    try {
      await _repository.deleteAvailabilitySlot(tutorId, slotId);
      Get.snackbar(
        "Berhasil",
        "Slot dihapus.",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        "Gagal",
        "Gagal menghapus slot: ${e.toString()}",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      // Re-throw error agar dialog tahu gagal
      rethrow;
    }
  }

  // --- HELPER: Format waktu lokal ---
  String formatLocalTime(DateTime utcTime) {
    final localTime = utcTime.toLocal();
    return DateFormat('EEE, d MMM yyyy HH:mm', 'id_ID').format(localTime);
  }

  // --- HELPER: Reset form input ---
  void resetForm() {
    selectedDate.value = null;
    startTime.value = null;
    endTime.value = null;
  }

  // --- HELPER: Konfirmasi hapus slot ---
  Future<bool> showDeleteConfirmation(String slotUid) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Slot'),
        content: const Text('Apakah kamu yakin ingin menghapus slot ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            onPressed: () async {
              // 1. TUTUP DIALOG KONFIRMASI
              Get.back(result: true); // Kembalikan true

              // 2. MULAI LOADING STATE
              isDeleting.value = true;

              // 3. LAKUKAN OPERASI HAPUS
              try {
                await removeSlot(slotUid);
                // Snackbar sukses sudah ada di removeSlot
              } catch (e) {
                // Snackbar gagal sudah ada di removeSlot
                print("Error during deletion: $e");
              } finally {
                // 4. HENTIKAN LOADING STATE (apapun hasilnya)
                isDeleting.value = false;
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }
}
