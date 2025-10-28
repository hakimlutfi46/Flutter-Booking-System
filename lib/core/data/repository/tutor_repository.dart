import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking_system/core/data/models/avability_model.dart';

class TutorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nama koleksi
  static const String _availabilityCollection = 'availability';

  // --- CREATE (Membuat Slot Jadwal Baru) ---
  Future<void> createAvailabilitySlot(AvailabilityModel slot) async {
    try {
      // Dapatkan referensi dokumen baru
      final docRef = _firestore
          .collection(_availabilityCollection)
          .doc(slot.uid);

      // Simpan data
      await docRef.set(slot.toJson());
    } catch (e) {
      // Re-throw exception agar bisa ditangkap oleh Controller
      throw Exception("Gagal membuat slot: ${e.toString()}");
    }
  }

  // --- READ (Membaca Jadwal Real-Time) ---
  Stream<List<AvailabilityModel>> getTutorAvailabilityStream(String tutorId) {
    // Query: Ambil semua dokumen di koleksi 'availability'
    // yang tutorId-nya sama dengan tutor yang login
    return _firestore
        .collection(_availabilityCollection)
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map(
          (query) =>
              query.docs
                  // Konversi setiap dokumen menjadi AvailabilityModel
                  .map((doc) => AvailabilityModel.fromJson(doc.data()))
                  .toList(),
        );
  }

  // --- DELETE (Menghapus Slot) ---
  Future<void> deleteAvailabilitySlot(String slotId) async {
    try {
      await _firestore.collection(_availabilityCollection).doc(slotId).delete();
    } catch (e) {
      throw Exception("Gagal menghapus slot: ${e.toString()}");
    }
  }

  // --- UPDATE (Mengubah status, misal: saat dibatalkan) ---
  Future<void> updateAvailabilityStatus(String slotId, String newStatus) async {
    try {
      await _firestore.collection(_availabilityCollection).doc(slotId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception("Gagal memperbarui status slot: ${e.toString()}");
    }
  }
}
