import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking_system/data/models/tutor_model.dart';
import 'package:flutter_booking_system/data/models/booking_model.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';
import 'package:flutter_booking_system/data/models/user_model.dart';

class DashboardController extends GetxController {
  final AuthController authC = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<DocumentSnapshot>? _tutorSubscription;
  StreamSubscription<QuerySnapshot>? _bookingsSubscription;

  // --- User & Role ---
  final Rxn<UserModel> user = Rxn<UserModel>();
  final isParent = false.obs;
  final isTutor = false.obs;
  var selectedIndex = 0.obs;

  // --- Tutor Data ---
  final Rxn<TutorModel> tutorData = Rxn<TutorModel>();
  final RxDouble tutorRating = 0.0.obs;

  // --- Statistik ---
  final RxInt todayConfirmedSessionsCount = 0.obs;
  final RxInt thisWeekConfirmedSessionsCount = 0.obs;
  final isLoadingStats = false.obs;

  // --- Jadwal Hari Ini ---
  final RxList<BookingModel> todayUpcomingSessions = <BookingModel>[].obs;
  final isLoadingTodaySessions = false.obs;

  String get userGreetingName =>
      user.value?.name ?? user.value?.email ?? 'Tamu';

  @override
  void onInit() {
    super.onInit();
    user.value = authC.firestoreUser.value;

    if (user.value != null) {
      isParent.value = user.value!.role == 'parent';
      isTutor.value = user.value!.role == 'tutor';

      if (isTutor.value) {
        fetchTutorDashboardData();
      }
    }
  }

  @override
  void onClose() {
    _tutorSubscription?.cancel();
    _bookingsSubscription?.cancel();
    super.onClose();
  }

  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }

  // --- FETCH DASHBOARD DATA REALTIME ---
  Future<void> fetchTutorDashboardData() async {
    final tutorId = user.value?.uid;
    if (tutorId == null) return;

    isLoadingStats.value = true;
    isLoadingTodaySessions.value = true;

    try {
      // 🔁 Realtime Tutor Data
      _tutorSubscription?.cancel();
      _tutorSubscription = _firestore
          .collection('tutors')
          .doc(tutorId)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              tutorData.value = TutorModel.fromJson(snapshot.data()!);
              tutorRating.value = tutorData.value?.rating ?? 0.0;
            } else {
              tutorData.value = null;
              tutorRating.value = 0.0;
            }
          });

      // 🔁 Realtime Bookings
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      final startOfWeek = startOfDay.subtract(
        Duration(days: startOfDay.weekday - 1),
      );
      final endOfWeek = startOfWeek.add(
        Duration(
          days: 6,
          hours: 23,
          minutes: 59,
          seconds: 59,
          milliseconds: 999,
        ),
      );

      _bookingsSubscription?.cancel();
      _bookingsSubscription = _firestore
          .collection('bookings')
          .where('tutorId', isEqualTo: tutorId)
          .where('status', isEqualTo: 'confirmed')
          .snapshots()
          .listen((snapshot) {
            final bookings =
                snapshot.docs
                    .map((doc) => BookingModel.fromJson(doc.data()))
                    .toList();

            // --- Today Upcoming Sessions ---
            todayUpcomingSessions.value =
                bookings.where((booking) {
                    final startUTC = booking.startUTC.toUtc();
                    return (startUTC.isAtSameMomentAs(startOfDay.toUtc()) ||
                            startUTC.isAfter(startOfDay.toUtc())) &&
                        (startUTC.isAtSameMomentAs(endOfDay.toUtc()) ||
                            startUTC.isBefore(endOfDay.toUtc()));
                  }).toList()
                  ..sort((a, b) => a.startUTC.compareTo(b.startUTC));

            // --- Today Confirmed Count ---
            todayConfirmedSessionsCount.value = todayUpcomingSessions.length;

            // --- This Week Confirmed Count ---
            thisWeekConfirmedSessionsCount.value =
                bookings.where((booking) {
                  final startUTC = booking.startUTC.toUtc();
                  return (startUTC.isAtSameMomentAs(startOfWeek.toUtc()) ||
                          startUTC.isAfter(startOfWeek.toUtc())) &&
                      (startUTC.isAtSameMomentAs(endOfWeek.toUtc()) ||
                          startUTC.isBefore(endOfWeek.toUtc()));
                }).length;

            isLoadingTodaySessions.value = false;
            isLoadingStats.value = false;
          });
    } catch (e) {
      print("Error fetching tutor dashboard data: $e");
      tutorData.value = null;
      tutorRating.value = 0.0;
      todayConfirmedSessionsCount.value = 0;
      thisWeekConfirmedSessionsCount.value = 0;
      todayUpcomingSessions.clear();
      isLoadingStats.value = false;
      isLoadingTodaySessions.value = false;
    }
  }
}
