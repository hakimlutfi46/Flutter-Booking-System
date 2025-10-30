import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking_system/data/models/avability_model.dart';
import 'package:flutter_booking_system/data/models/tutor_model.dart';

class TutorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nama koleksi
  static const String _availabilityCollection = 'availability';

  // --- CREATE (Membuat Slot Jadwal Baru) ---
  Future<void> createAvailabilitySlot(
    String tutorId,
    AvailabilityModel slot,
  ) async {
    final docRef = _firestore
        .collection('tutors')
        .doc(tutorId)
        .collection('availability')
        .doc(slot.uid);

    await docRef.set(slot.toJson());
  }

  // --- READ (Membaca Jadwal Real-Time) ---
  Stream<List<AvailabilityModel>> getTutorAvailabilityStream(String tutorId) {
    return _firestore
        .collection('tutors')
        .doc(tutorId)
        .collection('availability')
        .snapshots()
        .map(
          (query) =>
              query.docs
                  .map((doc) => AvailabilityModel.fromJson(doc.data()))
                  .toList(),
        );
  }

  // --- DELETE (Menghapus Slot) ---
  Future<void> deleteAvailabilitySlot(String tutorId, String slotId) async {
    try {
      await _firestore
          .collection('tutors')
          .doc(tutorId)
          .collection('availability')
          .doc(slotId)
          .delete();
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

  Future<TutorModel?> getTutorById(String tutorId) async {
    try {
      final doc = await _firestore.collection('tutors').doc(tutorId).get();
      if (!doc.exists) return null;
      return TutorModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception("Gagal memuat data tutor: ${e.toString()}");
    }
  }
}
