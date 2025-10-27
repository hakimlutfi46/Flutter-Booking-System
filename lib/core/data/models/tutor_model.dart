// lib/data/models/tutor_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorModel {
  final String uid; // Sama dengan UserModel.uid
  final String name; // Diambil dari UserModel saat pertama kali dibuat
  final String subject;
  final String timezone; // Penting untuk konversi waktu
  final double rating; // Contoh field tambahan

  TutorModel({
    required this.uid,
    required this.name,
    required this.subject,
    required this.timezone,
    this.rating = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'subject': subject,
    'timezone': timezone,
    'rating': rating,
  };

  factory TutorModel.fromJson(Map<String, dynamic> json) => TutorModel(
    uid: json['uid'] as String,
    name: json['name'] as String,
    subject: json['subject'] as String,
    timezone: json['timezone'] as String,
    rating: (json['rating'] as num).toDouble(),
  );
}
