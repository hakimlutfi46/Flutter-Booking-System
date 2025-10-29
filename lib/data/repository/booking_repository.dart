import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking_system/data/models/avability_model.dart';
import 'package:flutter_booking_system/data/models/booking_model.dart';
import 'package:uuid/uuid.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  static const String _availabilityCollection = 'availability';
  static const String _bookingsCollection = 'bookings';

  // --- CREATE BOOKING (Operasi Inti) ---
  Future<void> createBooking({
    required AvailabilityModel slot,
    required String parentId,
    required String studentName,
  }) async {
    // 1. Dapatkan referensi dokumen untuk availability dan booking baru
    final availabilityRef = _firestore
        .collection(_availabilityCollection)
        .doc(slot.uid);
    final bookingRef = _firestore
        .collection(_bookingsCollection)
        .doc(_uuid.v4()); // Buat ID baru

    // 2. Buat instance BookingModel baru
    final newBooking = BookingModel(
      uid: bookingRef.id,
      sessionId: slot.uid, // Gunakan UID availability sebagai referensi
      tutorId: slot.tutorId,
      parentId: parentId,
      studentName: studentName,
      startUTC: slot.startUTC,
      endUTC: slot.endUTC,
      status: 'confirmed', // Status awal booking
    );

    // 3. Jalankan Transaction
    // Transaction memastikan kedua operasi (update & create) berhasil
    // atau keduanya gagal, mencegah data tidak konsisten.
    return _firestore.runTransaction((transaction) async {
      // Baca dulu dokumen availability (untuk memastikan masih 'open')
      final availabilitySnapshot = await transaction.get(availabilityRef);

      if (!availabilitySnapshot.exists) {
        throw Exception("Slot jadwal ini sudah tidak tersedia.");
      }

      final currentSlotData = AvailabilityModel.fromJson(
        availabilitySnapshot.data()!,
      );

      // Cek apakah statusnya masih 'open'
      if (currentSlotData.status != 'open') {
        throw Exception("Slot jadwal ini sudah dipesan orang lain.");
      }

      // Jika masih 'open', lanjutkan:
      // a. Update status availability menjadi 'closed'
      transaction.update(availabilityRef, {'status': 'closed'});

      // b. Buat dokumen booking baru
      transaction.set(bookingRef, newBooking.toJson());

      // Jika tidak ada error, transaction akan otomatis commit.
    });
  }

  // (Nanti bisa tambahkan fungsi lain: getMyBookings, cancelBooking, dll.)
}
