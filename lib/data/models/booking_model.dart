import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String uid;
  final String sessionId; // Terkait dengan SessionModel
  final String tutorId;
  final String parentId;
  final String studentName;
  final DateTime startUTC;
  final DateTime endUTC;
  final String status; // "confirmed" | "cancelled" | "attended" | "noShow"

  BookingModel({
    required this.uid,
    required this.sessionId,
    required this.tutorId,
    required this.parentId,
    required this.studentName,
    required this.startUTC,
    required this.endUTC,
    this.status = 'confirmed',
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'sessionId': sessionId,
    'tutorId': tutorId,
    'parentId': parentId,
    'studentName': studentName,
    'startUTC': Timestamp.fromDate(startUTC),
    'endUTC': Timestamp.fromDate(endUTC),
    'status': status,
    'createdAt': FieldValue.serverTimestamp(),
    'clientRequestId': 'mock-id', // Sesuai assignment
  };

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    uid: json['uid'],
    sessionId: json['sessionId'],
    tutorId: json['tutorId'],
    parentId: json['parentId'],
    studentName: json['studentName'],
    startUTC: (json['startUTC'] as Timestamp).toDate(),
    endUTC: (json['endUTC'] as Timestamp).toDate(),
    status: json['status'],
  );
}
