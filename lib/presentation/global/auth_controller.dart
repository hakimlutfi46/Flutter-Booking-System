import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_booking_system/data/models/user_model.dart';
import 'package:flutter_booking_system/core/navigation/routes.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rxn<User> firebaseUser = Rxn<User>();
  final Rxn<UserModel> firestoreUser = Rxn<UserModel>();

  User? get user => firebaseUser.value;

  final isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) {
    if (user == null) {
      // User logout
      firestoreUser.value = null;
      Get.offAllNamed(Routes.LOGIN);
    } else {
      _redirectToDashboard(user.uid);
    }
  }

  Future<void> loadFirestoreUser(String uid) async {
    // Hanya fetch jika datanya belum ada
    if (firestoreUser.value != null && firestoreUser.value!.uid == uid) return;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        firestoreUser.value = UserModel.fromJson(doc.data()!);
      } else {
        throw Exception("User record not found in Firestore.");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _redirectToDashboard(String uid) async {
    try {
      await loadFirestoreUser(uid);

      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data user: ${e.toString()}");
      await logout();
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

  Future<void> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    isLoading.value = true;
    try {
      // --- Simple, portable timezone fallback (no native plugin needed)
      // Bisa diganti menjadi null jika kamu tidak ingin menyimpan timezone
      final String timezone = DateTime.now().timeZoneName;

      // 1) buat user di Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2) jika berhasil, simpan record ke Firestore
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        UserModel newUser = UserModel(
          uid: uid,
          email: email,
          role: role,
          name: name,
          timezone: timezone, // portable fallback
        );

        // toJson() di UserModel sudah menambahkan createdAt: FieldValue.serverTimestamp()
        await _firestore
            .collection('users')
            .doc(uid)
            .set(newUser.toJson(), SetOptions(merge: true));
      }
      // Redirect akan diurus otomatis oleh _handleAuthChanged
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
    } catch (e) {
      // Tangkap error non-Firebase juga
      Get.snackbar("Gagal Register", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
