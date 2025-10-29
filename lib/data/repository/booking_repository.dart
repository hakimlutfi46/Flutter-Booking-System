import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking_system/data/models/avability_model.dart';
import 'package:flutter_booking_system/data/models/booking_model.dart';
import 'package:uuid/uuid.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  static const String _availabilityCollection = 'availability';
  static const String _bookingsCollection = 'bookings';
  static const String _tutorsCollection = 'tutors';

  // --- CREATE BOOKING (Operasi Inti) ---
  Future<void> createBooking({
    required AvailabilityModel slot,
    required String parentId,
    required String studentName,
  }) async {
    // 1. Dapatkan referensi dokumen untuk availability dan booking baru
    final availabilityRef = _firestore
        .collection(_tutorsCollection)
        .doc(slot.tutorId) // Perlu tutorId untuk path
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
      // Baca dulu dokumen availability
      final availabilitySnapshot = await transaction.get(availabilityRef);

      if (!availabilitySnapshot.exists) {
        throw Exception("Slot jadwal ini sudah tidak tersedia.");
      }

      final currentSlotData = AvailabilityModel.fromJson(
        availabilitySnapshot.data()!,
      );

      if (currentSlotData.status != 'open') {
        throw Exception("Slot jadwal ini sudah dipesan orang lain.");
      }

      // Jika masih 'open':
      // a. Update status availability menjadi 'closed'
      transaction.update(availabilityRef, {
        'status': 'closed',
      }); // 'closed' sesuai assignment

      // b. Buat dokumen booking baru
      transaction.set(bookingRef, newBooking.toJson());
    });
  }

  // --- READ MY BOOKINGS (BARU) ---
  Stream<List<BookingModel>> getMyBookingsStream(String parentId) {
    // Query: Ambil semua dokumen di 'bookings'
    // yang 'parentId'-nya sama dengan user yang login
    // Urutkan berdasarkan waktu mulai (yang terbaru/akan datang duluan)
    return _firestore
        .collection(_bookingsCollection)
        .where('parentId', isEqualTo: parentId)
        .orderBy('startUTC', descending: true) // Urutkan descending
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => BookingModel.fromJson(doc.data()))
                  .toList(),
        );
  }

  Future<void> cancelBooking(String bookingId) async {
    // 1. Dapatkan referensi dokumen booking
    final bookingRef = _firestore
        .collection(_bookingsCollection)
        .doc(bookingId);

    // 2. Jalankan Transaction
    return _firestore
        .runTransaction((transaction) async {
          // Baca dulu dokumen booking untuk mendapatkan sessionId dan tutorId
          final bookingSnapshot = await transaction.get(bookingRef);

          if (!bookingSnapshot.exists || bookingSnapshot.data() == null) {
            throw Exception("Booking tidak ditemukan.");
          }
          final bookingData = BookingModel.fromJson(bookingSnapshot.data()!);

          // Pastikan booking belum dibatalkan
          if (bookingData.status == 'cancelled') {
            print("Booking sudah dibatalkan sebelumnya.");
            return; // Tidak perlu melakukan apa-apa
          }

          // Dapatkan referensi dokumen availability yang sesuai
          final availabilityRef = _firestore
              .collection(_tutorsCollection)
              .doc(bookingData.tutorId)
              .collection(_availabilityCollection)
              .doc(bookingData.sessionId); // Gunakan sessionId dari booking

          // Update status booking menjadi 'cancelled'
          transaction.update(bookingRef, {'status': 'cancelled'});

          // Update status availability kembali menjadi 'open'
          // (Asumsi availability masih ada, mungkin perlu dicek jika ada kemungkinan terhapus)
          transaction.update(availabilityRef, {'status': 'open'});
        })
        .catchError((error) {
          // Tangani error transaction
          print("Error cancelling booking: $error");
          throw Exception("Gagal membatalkan booking: ${error.toString()}");
        });
  }
}
