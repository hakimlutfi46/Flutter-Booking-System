import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking_system/data/models/avability_model.dart';
import 'package:flutter_booking_system/data/models/tutor_model.dart';

class ParentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _tutorsCollection = 'tutors';
  // 2. Tambahkan nama sub-koleksi
  static const String _availabilitySubCollection = 'availability';

  // --- READ TUTORS (Tetap sama) ---
  Future<List<TutorModel>> getAllTutors() async {
    try {
      final querySnapshot =
          await _firestore.collection(_tutorsCollection).get();
      return querySnapshot.docs
          .map((doc) => TutorModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Gagal mengambil data tutor: ${e.toString()}");
    }
  }

  // --- READ TUTOR BY ID (BARU - diperlukan controller) ---
  Future<TutorModel?> getTutorById(String tutorId) async {
    try {
      final docSnapshot =
          await _firestore.collection(_tutorsCollection).doc(tutorId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return TutorModel.fromJson(docSnapshot.data()!);
      }
      return null; // Tutor tidak ditemukan
    } catch (e) {
      throw Exception("Gagal mengambil detail tutor: ${e.toString()}");
    }
  }

  // --- READ AVAILABILITY (UPDATE DI SINI) ---
  Stream<List<AvailabilityModel>> getTutorAvailabilityStream(String tutorId) {
    // 3. UBAH QUERY UNTUK MENARGETKAN SUB-KOLEKSI
    return _firestore
        .collection(_tutorsCollection) // <-- Mulai dari 'tutors'
        .doc(tutorId) // <-- Pilih dokumen tutor spesifik
        .collection(
          _availabilitySubCollection,
        ) // <-- Masuk ke sub-koleksi 'availability'
        .where('status', isEqualTo: 'open') // <-- Filter status 'open'
        .orderBy('startUTC') // <-- Urutkan berdasarkan waktu mulai
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AvailabilityModel.fromJson(doc.data()))
                  .toList(),
        );
  }
}
