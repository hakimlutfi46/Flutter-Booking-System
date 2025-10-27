// lib/data/models/session_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String uid;
  final String tutorId;
  final DateTime startUTC;
  final DateTime endUTC;
  final String status; // "scheduled" | "cancelled" | "completed"

  SessionModel({
    required this.uid,
    required this.tutorId,
    required this.startUTC,
    required this.endUTC,
    this.status = 'scheduled',
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'tutorId': tutorId,
    'startUTC': Timestamp.fromDate(startUTC),
    'endUTC': Timestamp.fromDate(endUTC),
    'status': status,
    'capacity': 1, // Sesuai assignment (1-to-1)
  };

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    uid: json['uid'],
    tutorId: json['tutorId'],
    startUTC: (json['startUTC'] as Timestamp).toDate(),
    endUTC: (json['endUTC'] as Timestamp).toDate(),
    status: json['status'],
  );
}
