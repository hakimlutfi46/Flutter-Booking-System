import 'package:flutter_booking_system/data/repository/booking_repository.dart';
import 'package:flutter_booking_system/data/repository/parent_repository.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart'; // Untuk dialog

// Import dependencies
import 'package:flutter_booking_system/data/models/tutor_model.dart';
import 'package:flutter_booking_system/data/models/avability_model.dart'; // Pastikan path benar
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';

class TutorDetailController extends GetxController {
  // Instance dependencies (diambil dari binding)
  final ParentRepository _parentRepository = Get.find<ParentRepository>();
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();
  final AuthController authC = Get.find<AuthController>();

  // ID tutor diambil dari argumen navigasi
  late String tutorId;

  // State untuk menyimpan data tutor dan jadwal
  final Rxn<TutorModel> tutor = Rxn<TutorModel>();
  final RxList<AvailabilityModel> availabilitySlots = <AvailabilityModel>[].obs;
  // 1. HAPUS selectedSlot karena tidak dipakai lagi untuk FAB
  // final Rxn<AvailabilityModel> selectedSlot = Rxn<AvailabilityModel>();

  // State loading
  final isLoadingTutor = true.obs;
  final isLoadingSlots = true.obs;
  final isBooking = false.obs; // Untuk loading saat proses booking

  @override
  void onInit() {
    super.onInit();
    // Pastikan argumen tidak null sebelum di-assign
    if (Get.arguments is String) {
      tutorId = Get.arguments as String;
      fetchTutorDetails();
      fetchAvailabilitySlots();
    } else {
      Get.snackbar("Error", "Tutor id is't valid");
      Get.back();
    }
  }

  // --- FETCH DATA (Tidak berubah) ---
  Future<void> fetchTutorDetails() async {
    try {
      isLoadingTutor.value = true;
      tutor.value = await _parentRepository.getTutorById(tutorId);
      if (tutor.value == null) {
        Get.snackbar("Error", "Tutor data not found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch tutor: ${e.toString()}");
    } finally {
      isLoadingTutor.value = false;
    }
  }

  void fetchAvailabilitySlots() {
    isLoadingSlots.value = true;
    _parentRepository
        .getTutorAvailabilityStream(tutorId)
        .listen((data) {
          availabilitySlots.value =
              data.where((slot) => slot.status == 'open').toList();
          isLoadingSlots.value = false;
        })
        .onError((error) {
          if (authC.firestoreUser.value?.role == 'parent') {
            Get.snackbar("Error", "Failed to fetch availability: ${error.toString()}");
          }
          print("Availability Stream Error (Tutor Detail): $error");
          isLoadingSlots.value = false;
        });
  }

  // --- LOGIKA UI (Helper format waktu tidak berubah) ---
  String formatLocalTimeRange(DateTime startUTC, DateTime endUTC) {
    final startLocal = startUTC.toLocal();
    final endLocal = endUTC.toLocal();
    return "${DateFormat('EEE, d MMM yyyy', 'id_ID').format(startLocal)} • ${DateFormat('HH:mm').format(startLocal)} - ${DateFormat('HH:mm').format(endLocal)}";
  }

  // --- LOGIKA BOOKING ---

  // 2. UBAH FUNGSI INI: Terima 'slot' sebagai parameter
  void showBookingConfirmationDialog(AvailabilityModel slot) {
    // Hapus pengecekan selectedSlot.value
    if (tutor.value == null) return;

    // 'slot' sekarang didapat dari parameter
    final tutorData = tutor.value!;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Booking Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Agar dialog tidak terlalu besar
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are booking a session with:'),
            const SizedBox(height: 8),
            Text(
              tutorData.name,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Subjek: ${tutorData.subject}'),
            const SizedBox(height: 16),
            Text('At the following time:'),
            const SizedBox(height: 8),
            Text(
              formatLocalTimeRange(slot.startUTC, slot.endUTC),
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Make sure the time matches your time zone.',
              style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Hanya tutup dialog
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Tutup dialog konfirmasi
              // 3. KIRIM 'slot' ke processBooking
              processBooking(slot);
            },
            child: const Text('Yes, Confirm'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // 4. UBAH FUNGSI INI: Terima 'slot' sebagai parameter
  Future<void> processBooking(AvailabilityModel slotToBook) async {
    // Validasi awal (Hapus pengecekan selectedSlot.value)
    if (tutor.value == null || authC.user == null) {
      Get.snackbar("Error", "Incomplete booking data");
      return;
    }

    isBooking.value = true; // Mulai loading
    // 'slotToBook' sekarang didapat dari parameter
    final parentId = authC.user!.uid;
    final studentName = authC.firestoreUser.value?.name ?? "Siswa";

    try {
      // Panggil Repository dengan slot yang diterima
      await _bookingRepository.createBooking(
        slot: slotToBook, // Gunakan parameter slotToBook
        parentId: parentId,
        studentName: studentName,
      );

      // --- Tidak perlu reset selectedSlot.value ---
      // selectedSlot.value = null;

      // Tampilkan notifikasi sukses
      Get.snackbar(
        "Booking Successful!",
        "Session with ${tutor.value!.name} has been confirmed.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () {            
          },
          child: const Text(
            "Add to Calendar",
            style: TextStyle(color: Colors.white),
          ),
        ),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      print(e); // Tetap log error
      Get.snackbar(
        "Failed Booking",
        "An error has occurred: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isBooking.value = false; // Hentikan loading
    }
  }
}
