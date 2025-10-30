import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/utils/formatter_utils.dart';
import 'package:flutter_booking_system/data/models/booking_model.dart';
import 'package:flutter_booking_system/data/repository/booking_repository.dart';
import 'package:flutter_booking_system/data/repository/tutor_repository.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';
import 'package:flutter_booking_system/presentation/widgets/dialog/booking_detail_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/presentation/widgets/dialog/app_confirmation.dart';
import 'package:flutter_booking_system/presentation/widgets/snackbar/app_snackbar.dart';
import 'package:flutter_booking_system/core/navigation/routes.dart';

enum BookingStatusFilter { upcoming, past, cancelled }

class MyBookingsController extends GetxController {
  final BookingRepository _repository = Get.find<BookingRepository>();
  final AuthController authC = Get.find<AuthController>();
  final TutorRepository _tutorRepo = Get.find<TutorRepository>();

  // State
  final RxList<BookingModel> allbookings = <BookingModel>[].obs;
  final RxList<BookingModel> filteredBookings = <BookingModel>[].obs;
  final Rx<BookingStatusFilter> selectedStatus =
      BookingStatusFilter.upcoming.obs;

  final isLoading = true.obs;
  final isProcessing = false.obs;
  StreamSubscription<List<BookingModel>>? _bookingSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchMyBookingsStream();
    ever(selectedStatus, (_) => _filterBookings());
    ever(allbookings, (_) => _filterBookings());
  }

  @override
  void onClose() {
    _bookingSubscription?.cancel();
    super.onClose();
  }

  // --- Fetch Data (Tidak berubah) ---
  void fetchMyBookingsStream() {
    final parentId = authC.user?.uid;
    if (parentId == null) {
      // Gunakan AppSnackbar
      AppSnackbar.show(
        title: "Error",
        message: "User not found.",
        type: SnackbarType.error,
      );
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _bookingSubscription?.cancel();

    _bookingSubscription = _repository
        .getMyBookingsStream(parentId)
        .listen(
          (bookings) {
            allbookings.assignAll(bookings);
            isLoading.value = false;
          },
          onError: (error) {
            print("Firestore Stream Error: $error");
            // AppSnackbar.show(
            //   title: "Error",
            //   message: "Gagal memuat daftar booking: ${error.toString()}",
            //   type: SnackbarType.error,
            // );
            isLoading.value = false;
          },
        );
  }

  void _filterBookings() {
    final now = DateTime.now();
    List<BookingModel> result = [];
    switch (selectedStatus.value) {
      case BookingStatusFilter.upcoming:
        result =
            allbookings
                .where(
                  (b) => b.status == 'confirmed' && b.startUTC.isAfter(now),
                )
                .toList();
        break;
      case BookingStatusFilter.past:
        result =
            allbookings
                .where((b) => b.status != 'cancelled' && b.endUTC.isBefore(now))
                .toList();
        break;
      case BookingStatusFilter.cancelled:
        result = allbookings.where((b) => b.status == 'cancelled').toList();
        break;
    }
    filteredBookings.assignAll(result);
  }

  void changeTab(BookingStatusFilter filter) {
    selectedStatus.value = filter;
  }

  // --- IMPLEMENTASI AKSI ---

  // 1. Fungsi Cancel Booking (Sudah Diimplementasikan)
  Future<void> cancelBooking(String bookingId) async {
    final bool confirmed = await AppConfirmation.show(
      title: "Batalkan Booking",
      message:
          "Apakah Anda yakin ingin membatalkan booking ini? Slot waktu akan dibuka kembali.",
      confirmText: "Ya, Batalkan",
      cancelText: "Batal",
      confirmColor: Colors.red,
      icon: Icons.cancel_outlined,
    );

    if (!confirmed) return;

    isProcessing.value = true;
    try {
      // Panggil repository untuk cancel
      await _repository.cancelBooking(bookingId);

      // Tampilkan snackbar sukses dari helper
      AppSnackbar.show(
        title: "Success",
        message: "The booking has been successfully canceled.",
        type: SnackbarType.success,
      );
    } catch (e) {
      // Tampilkan snackbar error dari helper
      AppSnackbar.show(
        title: "Failed",
        message: "Failed to cancel booking: ${e.toString()}",
        type: SnackbarType.error,
      );
    } finally {
      isProcessing.value = false; // Hentikan loading
    }
  }

  // 2. Fungsi Rebook Booking (Diimplementasikan)
  Future<void> rebookBooking(BookingModel booking) async {
    final bool confirmed = await AppConfirmation.show(
      title: "Rebook Sesi",
      message:
          "Sesi ini akan dibatalkan dan Anda akan diarahkan untuk memilih jadwal baru. Lanjutkan?",
      confirmText: "Ya, Rebook",
      cancelText: "Tidak",
      confirmColor: Colors.blue,
      icon: Icons.replay_outlined,
    );

    if (!confirmed) return;

    isProcessing.value = true;
    try {
      // Batalkan booking lama (seperti cancel)
      await _repository.cancelBooking(booking.uid);

      // Navigasi ke Halaman Detail Tutor untuk memilih slot baru
      Get.toNamed(Routes.TUTOR_DETAIL, arguments: booking.tutorId);

      // Tampilkan info untuk user
      await Future.delayed(const Duration(milliseconds: 300));
      AppSnackbar.show(
        title: "Info",
        message: "Please select an alternative schedule for this session.",
        type: SnackbarType.neutral,
      );
    } catch (e) {
      AppSnackbar.show(
        title: "Failed",
        message: "Failed to start the rebooking process: ${e.toString()}",
        type: SnackbarType.error,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // 3. Fungsi Lihat Detail (Diimplementasikan)
  Future<void> viewBookingDetail(BookingModel booking) async {
    final formattedTime = FormatterUtils.formatBookingTime(
      booking.startUTC,
      booking.endUTC,
    );

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final tutor = await _tutorRepo.getTutorById(booking.tutorId);

      Get.back();
      Get.dialog(
        BookingDetailDialog(
          booking: booking,
          formattedTime: formattedTime,
          tutor: tutor,
        ),
      );
    } catch (e) {
      Get.back();
      Get.dialog(
        BookingDetailDialog(booking: booking, formattedTime: formattedTime),
      );

      AppSnackbar.show(
        title: "Error",
        message: "Failed to load tutor: ${e.toString()}",
        type: SnackbarType.error,
      );
    }
  }

  List<BookingModel> getBookingsByFilter(BookingStatusFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case BookingStatusFilter.upcoming:
        return allbookings
            .where((b) => b.status == 'confirmed' && b.startUTC.isAfter(now))
            .toList();
      case BookingStatusFilter.past:
        return allbookings
            .where((b) => b.status != 'cancelled' && b.endUTC.isBefore(now))
            .toList();
      case BookingStatusFilter.cancelled:
        return allbookings.where((b) => b.status == 'cancelled').toList();
    }
  }
}
