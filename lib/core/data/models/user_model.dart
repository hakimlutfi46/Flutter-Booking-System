// lib/domain/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role;
  final String? name; // Dibuat nullable, bisa diisi nanti
  final String? timezone; // Dibuat nullable, bisa diisi nanti

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.timezone,
  });

  // 1. Fungsi untuk MENGUBAH UserModel MENJADI Map (untuk simpan ke Firestore)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'timezone': timezone,
      // Kita tambahkan createdAt untuk data baru
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // 2. Fungsi untuk MEMBUAT UserModel DARI Map (saat ambil data dari Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      name: json['name'] as String?,
      timezone: json['timezone'] as String?,
    );
  }
}
