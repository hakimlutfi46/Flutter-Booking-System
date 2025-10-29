import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking_system/data/models/booking_model.dart';

class TutorSessionsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _bookingsCollection = 'bookings';
  static const String _tutorsCollection = 'tutors';
  static const String _availabilitySubCollection = 'availability';

  // --- READ MY UPCOMING SESSIONS (Real-time) ---
  Stream<List<BookingModel>> getTutorUpcomingSessions(String tutorId) {
    // Ambil semua sesi yang statusnya 'confirmed' dan waktunya masih di masa depan
    final now = DateTime.now().toUtc();

    return _firestore
        .collection(_bookingsCollection)
        .where('tutorId', isEqualTo: tutorId)
        .where('status', isEqualTo: 'confirmed')
        .where('startUTC', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy(
          'startUTC',
          descending: false,
        ) // Urutkan dari yang paling dekat
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => BookingModel.fromJson(doc.data()))
                  .toList(),
        );
  }

  // --- UPDATE SESSION STATUS (Cancel atau Complete) ---
  Future<void> updateSessionStatus(
    String bookingId,
    String tutorId,
    String newStatus,
  ) async {
    final bookingRef = _firestore
        .collection(_bookingsCollection)
        .doc(bookingId);

    // Jalankan Transaction untuk keamanan data
    return _firestore
        .runTransaction((transaction) async {
          final bookingSnapshot = await transaction.get(bookingRef);

          if (!bookingSnapshot.exists || bookingSnapshot.data() == null) {
            throw Exception("Sesi booking tidak ditemukan.");
          }
          final bookingData = BookingModel.fromJson(bookingSnapshot.data()!);

          // Dapatkan referensi dokumen availability yang sesuai
          final availabilityRef = _firestore
              .collection(_tutorsCollection)
              .doc(tutorId)
              .collection(_availabilitySubCollection)
              .doc(
                bookingData.sessionId,
              ); // sessionId adalah ID slot availability

          // 1. Update status booking
          transaction.update(bookingRef, {'status': newStatus});

          // 2. LOGIKA BARU: Jika status BARU adalah 'cancelled' atau 'completed', buka slot/hapus slot.
          if (newStatus == 'cancelled') {
            // Batalkan: Buka kembali slot availability
            transaction.update(availabilityRef, {'status': 'open'});
          } else if (newStatus == 'completed') {
            // Selesai: Hapus slot availability karena sudah tidak relevan
            transaction.delete(availabilityRef); // <-- TAMBAHKAN DELETE INI
          }
        })
        .catchError((error) {
          print("Error updating session status: $error");
          throw Exception("Gagal memperbarui status sesi: ${error.toString()}");
        });
  }
}
