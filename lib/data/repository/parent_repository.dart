import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking_system/data/models/avability_model.dart';
import 'package:flutter_booking_system/data/models/tutor_model.dart';

class ParentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _tutorsCollection = 'tutors';

  static const String _availabilityCollection = 'availability';

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

  Future<TutorModel?> getTutorById(String tutorId) async {
    try {
      final docSnapshot =
          await _firestore.collection(_tutorsCollection).doc(tutorId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return TutorModel.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      throw Exception("Gagal mengambil detail tutor: ${e.toString()}");
    }
  }

  Stream<List<AvailabilityModel>> getTutorAvailabilityStream(String tutorId) {
    return _firestore
        .collection(_availabilityCollection)
        .where('tutorId', isEqualTo: tutorId) // Filter berdasarkan tutorId
        .where('status', isEqualTo: 'open') // Hanya ambil yang statusnya 'open'
        .orderBy(
          'startUTC',
          descending: false,
        ) // Urutkan berdasarkan waktu mulai (paling awal dulu)
        .snapshots()
        .map(
          (query) =>
              query.docs
                  .map((doc) => AvailabilityModel.fromJson(doc.data()))
                  .toList(),
        );
  }
}
