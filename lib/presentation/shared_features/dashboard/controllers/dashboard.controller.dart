import 'dart:async'; // Untuk StreamSubscription
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking_system/data/models/tutor_model.dart';
import 'package:flutter_booking_system/data/models/booking_model.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';
import 'package:flutter_booking_system/data/models/user_model.dart';
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  final AuthController authC = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream Subscriptions
  StreamSubscription<DocumentSnapshot>? _tutorSubscription;
  StreamSubscription<QuerySnapshot>?
  _todaySessionsSubscription; // Khusus hari ini
  // Kita tidak perlu stream untuk count mingguan, cukup one-time fetch

  // State User & Role
  final Rxn<UserModel> user = Rxn<UserModel>();
  final isParent = false.obs;
  final isTutor = false.obs;
  var selectedIndex = 0.obs;

  // State Tutor Data
  final Rxn<TutorModel> tutorData = Rxn<TutorModel>();
  final RxDouble tutorRating = 0.0.obs;

  // State Statistik
  final RxInt todayConfirmedSessionsCount = 0.obs;
  final RxInt thisWeekConfirmedSessionsCount = 0.obs;
  final isLoadingStats = false.obs;

  // State Jadwal Hari Ini
  final RxList<BookingModel> todayUpcomingSessions = <BookingModel>[].obs;
  final isLoadingTodaySessions = false.obs;

  String get userGreetingName =>
      user.value?.name ?? user.value?.email ?? 'Tamu';

  @override
  void onInit() {
    super.onInit();
    // Gunakan listener Rx untuk user agar data tutor/stats di-fetch saat user siap
    ever(authC.firestoreUser, _handleUserReady);
    // Panggil sekali saat init jika user sudah ada
    _handleUserReady(authC.firestoreUser.value);
  }

  // Fungsi yang dipanggil saat data user (dari AuthController) siap
  void _handleUserReady(UserModel? firestoreUser) {
    user.value = firestoreUser;
    if (user.value != null) {
      isParent.value = user.value!.role == 'parent';
      isTutor.value = user.value!.role == 'tutor';

      if (isTutor.value) {
        // Panggil fungsi fetch/stream baru
        listenToTutorData();
        fetchWeeklyStats(); // Fetch mingguan cukup sekali
        listenToTodaySessions(); // Stream khusus hari ini
      } else {
        // Jika bukan tutor, pastikan data tutor bersih
        _cancelAllSubscriptions();
        resetTutorData();
      }
    } else {
      // Jika user null (logout)
      _cancelAllSubscriptions();
      resetTutorData();
    }
  }

  @override
  void onClose() {
    _cancelAllSubscriptions(); // Batalkan semua stream saat controller ditutup
    super.onClose();
  }

  // Helper untuk membatalkan semua stream
  void _cancelAllSubscriptions() {
    _tutorSubscription?.cancel();
    _todaySessionsSubscription?.cancel();
    _tutorSubscription = null;
    _todaySessionsSubscription = null;
  }

  // Helper untuk mereset data tutor
  void resetTutorData() {
    tutorData.value = null;
    tutorRating.value = 0.0;
    todayConfirmedSessionsCount.value = 0;
    thisWeekConfirmedSessionsCount.value = 0;
    todayUpcomingSessions.clear();
    isLoadingStats.value = false;
    isLoadingTodaySessions.value = false;
  }

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }

  // --- STREAM DATA TUTOR REALTIME ---
  void listenToTutorData() {
    final tutorId = user.value?.uid;
    if (tutorId == null) return;

    isLoadingStats.value = true; // Set loading stats saat mulai listen tutor
    _tutorSubscription?.cancel();
    _tutorSubscription = _firestore
        .collection('tutors')
        .doc(tutorId)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              tutorData.value = TutorModel.fromJson(snapshot.data()!);
              tutorRating.value = tutorData.value?.rating ?? 0.0;
            } else {
              tutorData.value = null;
              tutorRating.value = 0.0;
            }
            // Set loading false SETELAH data tutor diterima
            // (Asumsi fetchWeeklyStats sudah jalan paralel)
            // isLoadingStats.value = false;
          },
          onError: (error) {
            print("Error listening to tutor data: $error");
            isLoadingStats.value = false;
          },
        );
  }

  // --- FETCH STATISTIK MINGGUAN (ONE-TIME) ---
  Future<void> fetchWeeklyStats() async {
    final tutorId = user.value?.uid;
    if (tutorId == null) return;

    isLoadingStats.value = true; // Set loading true
    try {
      // Hitung Sesi Confirmed Minggu Ini
      final todayLocal = DateTime.now();
      final startOfWeek = todayLocal.subtract(
        Duration(days: todayLocal.weekday - 1),
      );
      final startOfWeekUtc =
          DateTime(
            startOfWeek.year,
            startOfWeek.month,
            startOfWeek.day,
          ).toUtc();
      final endOfWeekUtc = startOfWeekUtc.add(
        const Duration(days: 7),
      ); // Sampai sebelum Senin depan

      // Gunakan .count().get() yang efisien
      final weekCountQuery =
          await _firestore
              .collection('bookings')
              .where('tutorId', isEqualTo: tutorId)
              .where('status', isEqualTo: 'confirmed')
              .where(
                'startUTC',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeekUtc),
              )
              .where('startUTC', isLessThan: Timestamp.fromDate(endOfWeekUtc))
              .count()
              .get();
      thisWeekConfirmedSessionsCount.value = weekCountQuery.count ?? 0;
    } catch (e) {
      print("Error fetching weekly stats: $e");
      thisWeekConfirmedSessionsCount.value = 0; // Reset jika error
    } finally {
      // Hanya set false jika isLoadingTodaySessions juga false
      if (!isLoadingTodaySessions.value) {
        isLoadingStats.value = false;
      }
    }
  }

  void listenToTodaySessions() {
    final tutorId = user.value?.uid;
    if (tutorId == null) return;

    isLoadingTodaySessions.value = true; // Set loading true

    // Tentukan rentang waktu hari ini dalam UTC
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toUtc();
    final endOfDay =
        DateTime(now.year, now.month, now.day, 23, 59, 59, 999).toUtc();

    _todaySessionsSubscription?.cancel();
    _todaySessionsSubscription = _firestore
        .collection('bookings')
        .where('tutorId', isEqualTo: tutorId)
        .where('status', isEqualTo: 'confirmed')
        .where(
          'startUTC',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('startUTC', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('startUTC')
        .snapshots()
        .listen(
          (snapshot) {
            final now = DateTime.now().toUtc();

            final allTodayBookings =
                snapshot.docs
                    .map((doc) => BookingModel.fromJson(doc.data()))
                    .toList();

            // Sesi yang masih 'Upcoming' adalah yang WAKTU SELESAI-nya (endUTC) masih di masa depan
            final upcoming =
                allTodayBookings
                    .where((booking) => booking.endUTC.isAfter(now))
                    .toList();

            // 3. Update list sesi hari ini
            todayUpcomingSessions.value = upcoming;

            // 4. Update count sesi hari ini secara realtime
            todayConfirmedSessionsCount.value = upcoming.length;

            // 5. Update count mingguan (asumsi sudah dipanggil fetchWeeklyStats)
            // (Tidak perlu dilakukan di sini karena fetchWeeklyStats adalah one-time fetch)

            isLoadingTodaySessions.value = false;
            // Set loading stats false jika fetchWeeklyStats sudah selesai
            if (!isLoadingStats.value) {
              // Cek status loading stats
              // isLoadingStats.value = false; // Tidak perlu di set lagi
            }
          },
          onError: (error) {
            print("Error listening to today sessions: $error");
            isLoadingTodaySessions.value = false;
          },
        );
  }
}
