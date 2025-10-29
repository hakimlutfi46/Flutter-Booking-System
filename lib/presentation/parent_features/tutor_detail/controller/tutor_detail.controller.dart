import 'package:flutter_booking_system/data/models/avability_model.dart';
import 'package:flutter_booking_system/data/models/tutor_model.dart';
import 'package:flutter_booking_system/data/repository/booking_repository.dart';
import 'package:flutter_booking_system/data/repository/parent_repository.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';

class TutorDetailController extends GetxController {
  // Instance dependencies
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();
  final ParentRepository _repository =
      Get.find<ParentRepository>(); // Dapatkan dari binding
  final AuthController authC = Get.find<AuthController>();

  // Ambil tutorId dari argumen navigasi
  late String tutorId;

  // State untuk menyimpan data tutor dan jadwal
  final Rxn<TutorModel> tutor = Rxn<TutorModel>();
  final RxList<AvailabilityModel> availabilitySlots = <AvailabilityModel>[].obs;
  final Rxn<AvailabilityModel> selectedSlot =
      Rxn<AvailabilityModel>(); // Slot yg dipilih user

  final isLoadingTutor = true.obs;
  final isLoadingSlots = true.obs;
  final isBooking = false.obs; // Untuk loading saat proses booking

  @override
  void onInit() {
    super.onInit();
    // Ambil tutorId dari arguments
    tutorId = Get.arguments as String;
    // Panggil fungsi fetch data
    fetchTutorDetails();
    fetchAvailabilitySlots();
  }

  // --- FETCH DATA ---

  Future<void> fetchTutorDetails() async {
    try {
      isLoadingTutor.value = true;
      tutor.value = await _repository.getTutorById(tutorId);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat detail tutor: ${e.toString()}");
    } finally {
      isLoadingTutor.value = false;
    }
  }

  void fetchAvailabilitySlots() {
    isLoadingSlots.value = true;
    // Gunakan stream dari repository
    _repository
        .getTutorAvailabilityStream(tutorId)
        .listen((data) {
          availabilitySlots.value = data;
          isLoadingSlots.value =
              false; // Set loading false setelah data pertama masuk
        })
        .onError((error) {
          Get.snackbar("Error", "Gagal memuat jadwal: ${error.toString()}");
          isLoadingSlots.value = false;
        });
  }

  // --- LOGIKA UI ---

  // Fungsi saat user memilih slot
  void selectSlot(AvailabilityModel slot) {
    selectedSlot.value = slot;
    _showBookingConfirmationDialog(); // Tampilkan dialog konfirmasi
  }

  // Helper untuk format waktu lokal
  String formatLocalTimeRange(DateTime startUTC, DateTime endUTC) {
    final startLocal = startUTC.toLocal();
    final endLocal = endUTC.toLocal();
    // Contoh format: Sen, 28 Okt 2025 • 10:00 - 11:00
    return "${DateFormat('EEE, d MMM yyyy').format(startLocal)} • ${DateFormat('HH:mm').format(startLocal)} - ${DateFormat('HH:mm').format(endLocal)}";
  }

  // --- LOGIKA BOOKING ---

  void _showBookingConfirmationDialog() {
    if (selectedSlot.value == null || tutor.value == null) return;

    final slot = selectedSlot.value!;
    final tutorData = tutor.value!;

    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Booking Sesi'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Agar dialog tidak terlalu besar
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Anda akan memesan sesi dengan:'),
            const SizedBox(height: 8),
            Text(
              tutorData.name,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Subjek: ${tutorData.subject}'),
            const SizedBox(height: 16),
            Text('Pada waktu:'),
            const SizedBox(height: 8),
            Text(
              formatLocalTimeRange(slot.startUTC, slot.endUTC),
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              selectedSlot.value = null; // Batalkan pilihan
              Get.back(); // Tutup dialog
            },
            child: const Text('Batal'),
          ),
          // Tombol konfirmasi akan memicu proses booking
          ElevatedButton(
            onPressed: () {
              Get.back(); // Tutup dialog dulu
              processBooking(); // Panggil fungsi booking
            },
            child: const Text('Ya, Konfirmasi'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk memproses booking (akan memanggil repository booking)
  Future<void> processBooking() async {
    // Validasi awal (pastikan slot, tutor, dan user ada)
    if (selectedSlot.value == null ||
        tutor.value == null ||
        authC.user == null) {
      Get.snackbar("Error", "Data tidak lengkap untuk booking.");
      return;
    }

    isBooking.value = true; // Mulai loading
    final slotToBook = selectedSlot.value!;
    final parentId = authC.user!.uid;
    // Ambil nama dari user model, beri default jika null
    final studentName = authC.firestoreUser.value?.name ?? "Siswa";

    try {
      // PANGGIL REPOSITORY BARU UNTUK MEMBUAT BOOKING
      // Ini akan menjalankan transaction (create booking + update availability)
      await _bookingRepository.createBooking(
        slot: slotToBook,
        parentId: parentId,
        studentName: studentName,
      );

      // Reset pilihan slot setelah booking berhasil
      selectedSlot.value = null;

      // Tampilkan notifikasi sukses
      Get.snackbar(
        "Booking Berhasil!",
        "Sesi dengan ${tutor.value!.name} telah dikonfirmasi.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () {
            /* TODO: Implement add to calendar */
          },
          child: const Text(
            "Add to Calendar",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      // (Opsional) Arahkan ke halaman My Bookings setelah sukses
      // Get.offAndToNamed(Routes.PARENT_MY_BOOKINGS);
    } catch (e) {
      // Tangani error dari repository (misal: slot sudah dipesan)
      Get.snackbar("Booking Gagal", "Terjadi kesalahan: ${e.toString()}");
      // Jangan reset pilihan jika gagal, biarkan user coba lagi
    } finally {
      isBooking.value = false; // Hentikan loading
    }
  }
}
