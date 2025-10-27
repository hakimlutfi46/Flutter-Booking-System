// lib/presentation/global/auth_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_booking_system/infrastructure/navigation/routes.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rxn<User> _user = Rxn<User>();
  User? get user => _user.value;

  final isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) {
    if (user == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case "invalid-email":
          errorMessage = "Format email yang kamu masukkan salah.";
          break;
        case "wrong-password":
          errorMessage = "Password yang kamu masukkan salah.";
          break;
        case "user-not-found":
          errorMessage = "Akun dengan email ini tidak ditemukan.";
          break;
        case "invalid-credential":
          errorMessage = "Email atau password salah.";
          break;
        default:
          errorMessage = "Terjadi kesalahan. Coba lagi nanti.";
      }
      Get.snackbar("Gagal Login", errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case "invalid-email":
          errorMessage = "Format email yang kamu masukkan salah.";
          break;
        case "email-already-in-use":
          errorMessage = "Email ini sudah terdaftar. Silakan login.";
          break;
        case "weak-password":
          errorMessage = "Password terlalu lemah. (Minimal 6 karakter)";
          break;
        default:
          errorMessage = "Terjadi kesalahan. Coba lagi nanti.";
      }
      Get.snackbar("Gagal Register", errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
