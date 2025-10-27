import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityModel {
  final String uid;
  final String tutorId;
  final DateTime startUTC;
  final DateTime endUTC;
  final String status;

  AvailabilityModel({
    required this.uid,
    required this.tutorId,
    required this.startUTC,
    required this.endUTC,
    this.status = 'open',
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'tutorId': tutorId,
    // Simpan sebagai Timestamp di Firestore
    'startUTC': Timestamp.fromDate(startUTC),
    'endUTC': Timestamp.fromDate(endUTC),
    'status': status,
  };

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) =>
      AvailabilityModel(
        uid: json['uid'],
        tutorId: json['tutorId'],
        startUTC: (json['startUTC'] as Timestamp).toDate(),
        endUTC: (json['endUTC'] as Timestamp).toDate(),
        status: json['status'],
      );
}
