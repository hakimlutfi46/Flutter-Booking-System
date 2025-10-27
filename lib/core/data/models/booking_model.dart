import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String uid; 
  final String availabilityId; 
  final String tutorId;
  final String parentId;
  final DateTime startUTC;
  final DateTime endUTC;
  final String status; 

  BookingModel({
    required this.uid,
    required this.availabilityId,
    required this.tutorId,
    required this.parentId,
    required this.startUTC,
    required this.endUTC,
    this.status = 'confirmed',
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'availabilityId': availabilityId,
    'tutorId': tutorId,
    'parentId': parentId,
    'startUTC': Timestamp.fromDate(startUTC),
    'endUTC': Timestamp.fromDate(endUTC),
    'status': status,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    uid: json['uid'],
    availabilityId: json['availabilityId'],
    tutorId: json['tutorId'],
    parentId: json['parentId'],
    startUTC: (json['startUTC'] as Timestamp).toDate(),
    endUTC: (json['endUTC'] as Timestamp).toDate(),
    status: json['status'],
  );
}
