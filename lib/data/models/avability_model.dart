import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityModel {
  final String uid;
  final String tutorId;
  final DateTime startUTC;
  final DateTime endUTC;
  final int capacity;
  final String status;

  AvailabilityModel({
    required this.uid,
    required this.tutorId,
    required this.startUTC,
    required this.endUTC,
    this.capacity = 1,
    this.status = 'open',
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'tutorId': tutorId,    
    'startUTC': Timestamp.fromDate(startUTC),
    'endUTC': Timestamp.fromDate(endUTC),
    'capacity': capacity,
    'status': status,
  };

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) =>
      AvailabilityModel(
        uid: json['uid'],
        tutorId: json['tutorId'],
        startUTC: (json['startUTC'] as Timestamp).toDate(),
        endUTC: (json['endUTC'] as Timestamp).toDate(),
        capacity: json['capacity'],
        status: json['status'],
      );
}
