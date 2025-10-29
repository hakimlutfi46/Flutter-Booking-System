import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_booking_system/data/models/tutor_model.dart';
import 'package:flutter_booking_system/data/models/user_model.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';
import 'package:flutter_booking_system/presentation/widgets/dialog/app_confirmation.dart';
import 'package:flutter_booking_system/presentation/widgets/snackbar/app_snackbar.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final AuthController authC = Get.find<AuthController>();
  // 1. TAMBAHKAN INSTANCE FIRESTORE
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get user => authC.firestoreUser.value;

  // 2. TAMBAHKAN STATE BARU UNTUK STATISTIK TUTOR
  final RxInt totalSessions = 0.obs;
  final RxDouble tutorRating = 0.0.obs;
  final isLoadingStats = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (user?.role == 'tutor') {
      fetchTutorStats();
    }
  }

  void logoutWithConfirmation() async {
    final confirmed = await AppConfirmation.show(
      title: "Konfirmasi Logout",
      message: "Apakah Anda yakin ingin keluar dari akun ini?",
      confirmText: "Logout",
      confirmColor: Colors.red,
      icon: Icons.logout,
    );

    if (!confirmed) return;

    // Kalau user menekan "Logout"
    authC.isLoading.value = true;
    try {
      await authC.logout();
      AppSnackbar.show(
        title: "Berhasil",
        message: "Anda telah keluar dari akun.",
        type: SnackbarType.success,
      );
    } catch (e) {
      AppSnackbar.show(
        title: "Gagal",
        message: "Gagal logout: ${e.toString()}",
        type: SnackbarType.error,
      );
    } finally {
      authC.isLoading.value = false;
    }
  }

  Future<void> fetchTutorStats() async {
    final tutorId = user?.uid;
    if (tutorId == null) return; // Pastikan UID ada

    isLoadingStats.value = true;
    try {
      // a) Ambil Rating dari koleksi 'tutors'
      final tutorDoc = await _firestore.collection('tutors').doc(tutorId).get();
      if (tutorDoc.exists && tutorDoc.data() != null) {
        // Asumsi model TutorModel sudah ada dan diimport
        final tutorData = TutorModel.fromJson(tutorDoc.data()!);
        tutorRating.value = tutorData.rating; // Ambil rating
      }

      // b) Hitung Total Sesi dari koleksi 'bookings'
      // Query: Hitung semua booking milik tutor ini yang statusnya 'attended' atau 'completed'
      final sessionsQuery =
          await _firestore
              .collection('bookings')
              .where('tutorId', isEqualTo: tutorId)
              // Sesuaikan status ini jika perlu
              .where('status', whereIn: ['attended', 'completed'])
              .count() // Hanya ambil jumlahnya (lebih efisien)
              .get();

      // PERBAIKAN: Tambahkan null check ?? 0
      totalSessions.value = sessionsQuery.count ?? 0; // Update jumlah sesi
    } catch (e) {
      Get.snackbar(
        "Error Statistik",
        "Gagal memuat data statistik: ${e.toString()}",
      );
    } finally {
      isLoadingStats.value = false;
    }
  }
}
