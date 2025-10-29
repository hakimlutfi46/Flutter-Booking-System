import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/navigation/routes.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';
import 'package:flutter_booking_system/presentation/widgets/loading_spinner.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/presentation/shared_features/dashboard/controllers/dashboard.controller.dart';
import 'package:flutter_booking_system/core/utils/formatter_utils.dart';

class TutorHomeTab extends StatelessWidget {
  const TutorHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(color: Colors.transparent),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          "Halo, ${dashboardController.userGreetingName}! 🎓",
                          style: Get.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Siap untuk mengajar hari ini?",
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Obx(() {
                    final bool isLoading =
                        dashboardController.isLoadingStats.value;
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.today_outlined,
                            label: "Hari Ini",
                            value:
                                dashboardController
                                    .todayConfirmedSessionsCount
                                    .value
                                    .toString(),
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.date_range_outlined,
                            label: "Minggu Ini",
                            value:
                                dashboardController
                                    .thisWeekConfirmedSessionsCount
                                    .value
                                    .toString(),
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.star,
                            label: "Rating",
                            value:
                                dashboardController.tutorRating.value
                                    .toString(),
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            // Quick Access Section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Akses Cepat",
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickAccessCard(
                      icon: Icons.edit_calendar,
                      iconColor: AppColors.primary,
                      title: "Publish Availability",
                      subtitle: "Atur jadwal kosongmu agar bisa dipesan",
                      onTap: () {
                        dashboardController.changeTabIndex(1);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildQuickAccessCard(
                      icon: Icons.event_available,
                      iconColor: AppColors.secondary,
                      title: "Upcoming Sessions",
                      subtitle: "Lihat daftar sesi yang sudah dipesan",
                      onTap: () {
                        Get.toNamed(Routes.TUTOR_SESSIONS);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Today's Schedule Section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                24,
                0,
                24,
                24,
              ), // Padding section
              sliver: SliverToBoxAdapter(
                child: Column(
                  // Column untuk header dan list
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Jadwal hari ini",
                          style: Get.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            dashboardController.changeTabIndex(
                              1,
                            ); // Arahkan ke tab Sesi jika ada
                            // Get.snackbar("Navigation", "View all sessions");
                          },
                          child: Text(
                            "View All",
                            style: Get.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Daftar Sesi (dalam Obx)
                    Obx(() {
                      // Handle loading state
                      if (dashboardController.isLoadingTodaySessions.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: LoadingSpinner(),
                        );
                      }
                      // Handle empty state
                      if (dashboardController.todayUpcomingSessions.isEmpty) {
                        return Container(
                          // Container untuk empty state
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(/* ... shadow ... */)],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                size: 30,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Tidak ada Sesi yang akan datang",
                                style: Get.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Tampilkan daftar sesi jika ada data
                      return Column(
                        // Gunakan map untuk iterasi list dari controller
                        children:
                            dashboardController.todayUpcomingSessions.map((
                              booking,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildSessionCard(
                                  // Ambil data dari 'booking' (BookingModel)
                                  time: FormatterUtils.formatTimeOnly(
                                    booking.startUTC,
                                  ),
                                  subject:
                                      dashboardController
                                          .tutorData
                                          .value
                                          ?.subject ??
                                      'Unknown Subject',
                                  studentName: booking.studentName,
                                  status: 'upcoming',
                                ),
                              );
                            }).toList(), // Konversi ke List<Widget>
                      );
                    }), // Akhir Obx
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Get.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard({
    required String time,
    required String subject,
    required String studentName,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.access_time, color: AppColors.secondary, size: 20),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: Get.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: Get.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      studentName,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
