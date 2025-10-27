import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/shared_features/profile/views/profile.screen.dart';
import 'package:flutter_booking_system/presentation/tutor_features/avability/views/avability.screen.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/presentation/shared_features/dashboard/controllers/dashboard.controller.dart';
import 'package:flutter_booking_system/presentation/parent_features/my_bookings/views/my_bookings.screen.dart';
import 'parent_home_tab.dart'; 
import 'tutor_home_tab.dart'; 
import 'package:flutter_booking_system/presentation/widgets/loading_spinner.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Halaman Profil"));
}

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  // 3. DAFTAR HALAMAN (TAB) UNTUK TIAP ROLE
  final List<Widget> parentPages = const [
    ParentHomeTab(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  final List<Widget> tutorPages = const [
    TutorHomeTab(),
    AvabilityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 4. BODY SEKARANG BERUBAH BERDASARKAN TAB
      body: Obx(() {
        // Cek dulu rolenya
        if (controller.isParent.value) {
          // Tampilkan halaman Parent berdasarkan tab yang aktif
          return parentPages[controller.selectedIndex.value];
        } else if (controller.isTutor.value) {
          // Tampilkan halaman Tutor berdasarkan tab yang aktif
          return tutorPages[controller.selectedIndex.value];
        }
        // Tampilan fallback jika role belum ke-load
        return const LoadingSpinner();
      }),

      // 5. BOTTOM NAVIGATION BAR TAMPIL BERDASARKAN ROLE
      bottomNavigationBar: Obx(() {
        if (controller.isParent.value) {
          return _buildParentBottomNav(); // Tampilkan Nav Bar Parent
        } else if (controller.isTutor.value) {
          return _buildTutorBottomNav(); // Tampilkan Nav Bar Tutor
        }
        // Jangan tampilkan apa-apa jika role belum jelas
        return const SizedBox.shrink();
      }),
    );
  }

  // 6. WIDGET BARU (UNTUK NAV BAR PARENT)
  Widget _buildParentBottomNav() {
    return Obx(
      () => BottomNavigationBar(
        currentIndex:
            controller.selectedIndex.value, // Dapatkan index dari controller
        onTap: controller.changeTabIndex, // Panggil fungsi di controller
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        // (Style ini akan mengambil warna dari app_theme.dart)
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Get.theme.primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // 7. WIDGET BARU (UNTUK NAV BAR TUTOR)
  Widget _buildTutorBottomNav() {
    return Obx(
      () => BottomNavigationBar(
        currentIndex: controller.selectedIndex.value,
        onTap: controller.changeTabIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            activeIcon: Icon(Icons.schedule),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Get.theme.primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // 8. HAPUS FUNGSI-FUNGSI LAMA INI
  // List<Widget> _buildParentWidgets() { ... }
  // List<Widget> _buildTutorWidgets() { ... }
}
