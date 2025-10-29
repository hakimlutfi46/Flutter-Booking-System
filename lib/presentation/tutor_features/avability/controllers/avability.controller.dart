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

  final isLoading = false.obs;

  // Variabel untuk menyimpan StreamSubscription
  StreamSubscription<List<AvailabilityModel>>? _availabilitySubscription;

  @override
  void onInit() {
    super.onInit();
    // 2. Tambahkan listener ke status login Firebase Auth
    // PERBAIKI: Berikan variabel Rxn<User> _firebaseUser ke 'ever'
    ever(authC.firebaseUser, _handleAuthChangesForStream);

    // 3. Panggil listener sekali saat init untuk state awal
    // (Menggunakan getter 'user' di sini tidak masalah)
    _handleAuthChangesForStream(authC.user);
  }

  @override
  void onClose() {
    _cancelAvailabilityStream(); // 4. Panggil fungsi cancel di onClose
    super.onClose();
  }

  // 5. Fungsi baru untuk menangani perubahan status login
  // Parameter 'firebaseUser' di sini adalah nama lokal, tidak masalah
  void _handleAuthChangesForStream(User? firebaseUser) {
    _cancelAvailabilityStream(); // Selalu batalkan stream lama dulu
    // Cek jika user login DAN rolenya tutor
    if (firebaseUser != null && authC.firestoreUser.value?.role == 'tutor') {
      // Mulai stream baru menggunakan UID user yang login
      fetchAvailabilityStream(firebaseUser.uid);
    } else {
      // Jika logout atau bukan tutor, bersihkan list
      availabilityList.clear();
    }
  }

  // 6. Fungsi untuk membatalkan stream (jika ada)
  void _cancelAvailabilityStream() {
    _availabilitySubscription?.cancel();
    _availabilitySubscription = null;
  }

  // --- READ (Membaca Jadwal Real-Time) ---
  // 7. Modifikasi: Terima tutorId sebagai parameter
  void fetchAvailabilityStream(String tutorId) {
    // Pastikan stream lama dibatalkan sebelum memulai yang baru
    _cancelAvailabilityStream();

    // Simpan subscription saat listen
    _availabilitySubscription = _repository
        .getTutorAvailabilityStream(tutorId)
        .listen(
          (data) {
            availabilityList.value = data;
          },
          onError: (error) {
            // Tangani error di sini
            // Hanya tampilkan snackbar jika user MASIH tutor
            if (authC.firestoreUser.value?.role == 'tutor') {
              Get.snackbar("Error", "Gagal memuat jadwal: ${error.toString()}");
            }
            print("Firestore Stream Error: $error"); // Log error untuk debug
          },
        );
  }

  // --- CREATE (Membuat Slot Baru) ---
  Future<void> addSlot() async {
    // ... (kode addSlot tidak berubah) ...
    if (selectedDate.value == null ||
        startTime.value == null ||
        endTime.value == null) {
      Get.snackbar("Perhatian", "Semua kolom tanggal dan waktu harus diisi!");
      return;
    }

    // Pastikan user masih login sebelum mencoba menambah slot
    // PERBAIKI: Gunakan getter 'user' yang benar
    final tutorId = authC.user?.uid;
    if (tutorId == null) {
      Get.snackbar("Error", "Sesi Anda telah berakhir. Silakan login kembali.");
      return;
    }

    isLoading.value = true;
    try {
      // final tutorId = authC.user!.uid; // Kita sudah cek null di atas
      final selectedDay = selectedDate.value!;

      // LOGIKA KONVERSI WAKTU (SANGAT PENTING!)
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

      // BUAT INSTANCE MODEL BARU (DENGAN CAPACITY)
      final newSlot = AvailabilityModel(
        uid: _uuid.v4(), // Buat ID unik dengan UUID
        tutorId: tutorId,
        startUTC: startUTC,
        endUTC: endUTC,
        capacity: 1, // Eksplisit tambahkan capacity
        status: 'open',
      );

      // KIRIM KE REPOSITORY
      await _repository.createAvailabilitySlot(newSlot);

      Get.snackbar(
        "Sukses!",
        "Slot jadwal berhasil ditambahkan.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal menambahkan slot: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // --- DELETE (Menghapus Slot) ---
  Future<void> removeSlot(String slotId) async {
    // Tambahkan pengecekan login sebelum hapus
    // PERBAIKI: Gunakan getter 'user' yang benar
    if (authC.user == null) {
      Get.snackbar("Error", "Sesi Anda telah berakhir.");
      return;
    }
    try {
      await _repository.deleteAvailabilitySlot(slotId);
      Get.snackbar("Berhasil", "Slot dihapus.");
    } catch (e) {
      Get.snackbar("Gagal", "Gagal menghapus slot: ${e.toString()}");
    }
  }

  // Helper format waktu (tidak berubah)
  String formatLocalTime(DateTime utcTime) {
    // Pastikan kamu sudah install package intl
    final localTime = utcTime.toLocal();
    return DateFormat(
      'EEE, d MMM yyyy HH:mm',
      'id_ID',
    ).format(localTime); // Tambahkan locale ID
  }
}
