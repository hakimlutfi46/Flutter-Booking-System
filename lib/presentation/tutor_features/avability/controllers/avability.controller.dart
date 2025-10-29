import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_booking_system/data/models/avability_model.dart';
import 'package:flutter_booking_system/data/repository/tutor_repository.dart';
import 'package:flutter_booking_system/presentation/widgets/dialog/app_confirmation.dart';
import 'package:flutter_booking_system/presentation/widgets/snackbar/app_snackbar.dart';
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
              AppSnackbar.show(
                title: "Error",
                message: "Gagal memuat jadwal : ${error.toString()}",
                type: SnackbarType.error,
              );
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
      AppSnackbar.show(
        title: "Perhatian!",
        message: "Semua kolom tanggal dan waktu harus diisi!",
        type: SnackbarType.warning,
      );
      return;
    }

    final tutorId = authC.user?.uid;
    if (tutorId == null) {
      AppSnackbar.show(
        title: "Error",
        message: "Sesi anda telah berakhir. Silahkan login kembali.",
        type: SnackbarType.error,
      );
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
        AppSnackbar.show(
          title: "Gagal",
          message: "Waktu selesai harus setelah waktu mulai.",
          type: SnackbarType.error,
        );
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

      AppSnackbar.show(
        title: "Berhasil",
        message: "Slot jadwal berhasil ditambahkan.",
        type: SnackbarType.success,
        position: SnackPosition.BOTTOM,
      );

      resetForm();

      await Future.delayed(const Duration(milliseconds: 1500));
      if (Get.isBottomSheetOpen ?? false) Get.back();
    } catch (e) {
      AppSnackbar.show(
        title: 'Error',
        message: 'Gagal menambahkan slot: ${e.toString()}',
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- DELETE (Hapus Slot) ---
  Future<void> removeSlot(String slotId) async {
    final tutorId = authC.user?.uid;
    if (tutorId == null) {
      AppSnackbar.show(
        title: "Error",
        message: "Sesi anda telah berakhir. Silahkan login kembali.",
        type: SnackbarType.error,
      );

      throw Exception("User not logged in"); // Lempar error agar bisa ditangkap
    }
    try {
      await _repository.deleteAvailabilitySlot(tutorId, slotId);

      AppSnackbar.show(
        title: 'Success',
        message: 'Slot dihapus',
        type: SnackbarType.success,
      );
    } catch (e) {
      AppSnackbar.show(
        title: 'Error',
        message: 'Gagal menghapus slot: ${e.toString()}',
        type: SnackbarType.error,
      );

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
    final confirmed = await AppConfirmation.show(
      title: "Hapus Slot",
      message: "Apakah kamu yakin ingin menghapus slot ini?",
      confirmText: "Hapus",
      cancelText: "Batal",
      confirmColor: Colors.red,
      icon: Icons.delete_outline,
    );

    if (!confirmed) return false;

    // Jika user menekan "Hapus"
    isDeleting.value = true;

    try {
      await removeSlot(slotUid);
      // Snackbar sukses/error sudah ditangani di removeSlot
      return true;
    } catch (e) {
      print("Error during deletion: $e");
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
