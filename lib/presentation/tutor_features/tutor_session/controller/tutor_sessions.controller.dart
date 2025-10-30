import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/utils/formatter_utils.dart'; 
import 'package:flutter_booking_system/data/models/booking_model.dart';
import 'package:flutter_booking_system/data/repository/tutor_session_repository.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/presentation/widgets/dialog/app_confirmation.dart'; 
import 'package:flutter_booking_system/presentation/widgets/snackbar/app_snackbar.dart';


class TutorSessionsController extends GetxController {
  final TutorSessionsRepository _repository = Get.find<TutorSessionsRepository>();
  final AuthController authC = Get.find<AuthController>();

  final RxList<BookingModel> upcomingSessions = <BookingModel>[].obs;
  final isLoading = true.obs;
  StreamSubscription<List<BookingModel>>? _sessionsSubscription;
  final isProcessing = false.obs; // State untuk loading aksi

  @override
  void onInit() {
    super.onInit();
    // Memastikan hanya tutor yang bisa menggunakan ini
    if (authC.firestoreUser.value?.role == 'tutor') {
      listenToUpcomingSessions();
    }
  }

  @override
  void onClose() {
    _sessionsSubscription?.cancel();
    super.onClose();
  }

  // --- READ: Mendengarkan Sesi yang Akan Datang (Real-time) ---
  void listenToUpcomingSessions() {
    final tutorId = authC.user?.uid;
    if (tutorId == null) return;

    isLoading.value = true;
    _sessionsSubscription?.cancel();

    _sessionsSubscription = _repository.getTutorUpcomingSessions(tutorId).listen(
      (sessions) {
        upcomingSessions.assignAll(sessions);
        isLoading.value = false;
      },
      onError: (error) {
        AppSnackbar.show(title: "Error", message: "Failed to load sesion: ${error.toString()}", type: SnackbarType.error);
        isLoading.value = false;
      },
    );
  }
  
  // --- Aksi Tutor: Menandai Sesi Selesai (Completed) ---
  Future<void> completeSession(String bookingId) async {
     final tutorId = authC.user?.uid;
     if (tutorId == null) return;

     final bool confirmed = await AppConfirmation.show(
       title: 'Sesi Selesai?',
       message: 'Konfirmasi sesi ini telah selesai. Status booking akan diubah menjadi COMPLETED.',
       confirmText: 'Ya, Selesai',
       confirmColor: Colors.green.shade600,
       icon: Icons.check_circle_outline,
     );

     if (!confirmed) return;
     isProcessing.value = true;

     try {
       await _repository.updateSessionStatus(bookingId, tutorId, 'completed');
       AppSnackbar.show(title: "Success", message: "The session is marked as complete.", type: SnackbarType.success);
     } catch (e) {
       AppSnackbar.show(title: "Failed", message: "Failed to complete session: ${e.toString()}", type: SnackbarType.error);
     } finally {
        isProcessing.value = false;
     }
  }

  // --- Aksi Tutor: Membatalkan Sesi (Juga membuka slot) ---
  Future<void> cancelSession(String bookingId) async {
    final tutorId = authC.user?.uid;
    if (tutorId == null) return;

    final bool confirmed = await AppConfirmation.show(
       title: 'Cancel Sesion?',
       message: 'The session will be canceled, and the time slot will be reopened.',
       confirmText: 'Yes, Cancel',
       confirmColor: Colors.red.shade600,
       icon: Icons.cancel_outlined,
     );

    if (!confirmed) return;
    isProcessing.value = true;

     try {
       await _repository.updateSessionStatus(bookingId, tutorId, 'cancelled');
       AppSnackbar.show(title: "Success", message: "The session has been canceled and the slot has been reopened.", type: SnackbarType.success);
     } catch (e) {
       AppSnackbar.show(title: "Failed", message: "Failed to cancel session: ${e.toString()}", type: SnackbarType.error);
     } finally {
        isProcessing.value = false;
     }
  }
  
  // --- Aksi Tutor: Lihat Detail Sesi ---
  void viewSessionDetail(BookingModel session) {
    // Tampilkan detail sesi dalam dialog
    final formattedTime = FormatterUtils.formatTimeRange(session.startUTC, session.endUTC);

    Get.dialog(AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Session Detail'),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Student: ${session.studentName}', style: Get.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Time: $formattedTime', style: Get.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('Status: ${session.status.toUpperCase()}', style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: session.status == 'confirmed' ? Colors.green.shade600 : Colors.red.shade600)),
              const SizedBox(height: 16),
              Text('Booking ID: ${session.uid}', style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ]),
        actions: [TextButton(onPressed: Get.back, child: const Text('Tutup'))],
      ));
  }
}