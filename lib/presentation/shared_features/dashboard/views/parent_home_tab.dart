// lib/presentation/shared_features/dashboard/views/parent_home_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/navigation/routes.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';
import 'package:flutter_booking_system/core/utils/formatter_utils.dart';
import 'package:flutter_booking_system/presentation/widgets/card/activity_card.dart';
import 'package:flutter_booking_system/presentation/widgets/card/quick_access_card.dart';
import 'package:flutter_booking_system/presentation/widgets/card/stat_card.dart';
import 'package:flutter_booking_system/presentation/widgets/home_header.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/presentation/shared_features/dashboard/controllers/dashboard.controller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class ParentHomeTab extends StatelessWidget {
  const ParentHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                ),

                // Content di atas background
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting text
                      Obx(
                        () => RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Halo, ',
                                style: Get.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: dashboardController.userGreetingName,
                                style: Get.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const TextSpan(
                                text: ' 👋',
                                style: TextStyle(fontSize: 26),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        "Let's learn with a tutor today",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => StatCard(
                                icon: Icons.calendar_today,
                                iconSize: 33,
                                label: "Upcoming",
                                value:
                                    dashboardController.parentUpcomingCount
                                        .toString(),
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(
                              () => StatCard(
                                icon: Icons.check_circle_outline,
                                iconSize: 33,
                                label: "Completed",
                                value:
                                    dashboardController.parentCompletedCount
                                        .toString(),
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24), // Padding bawah
                    ],
                  ),
                ),
              ],
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
                    "Quick Access",
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  QuickAccessCard(
                    icon: Icons.search,
                    iconColor: AppColors.primary,
                    title: "Book a Session",
                    subtitle: "Search for tutors by name of subject",
                    onTap: () => Get.toNamed(Routes.SEARCH_TUTOR),
                  ),
                  const SizedBox(height: 12),
                  QuickAccessCard(
                    icon: Icons.event_note,
                    iconColor: AppColors.secondary,
                    title: "My Bookings",
                    subtitle: "See all your booked sessions",
                    onTap: () => dashboardController.changeTabIndex(1),
                  ),
                ],
              ),
            ),
          ),

          // Recent Activity Section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            sliver: SliverToBoxAdapter(
              child: Obx(() {
                if (dashboardController.isLoadingParentStats.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul tetap tampil
                    Text(
                      "Recent Activity",
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),

                    if (dashboardController.recentActivities.isEmpty)
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          width: double.infinity,
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 30,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "There is no recent activity",
                                style: Get.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...dashboardController.recentActivities.map((activity) {
                        final tutorName =
                            activity['tutorName'] ?? 'Unknown Tutor';
                        final subject = activity['subject'] ?? '-';
                        final status = activity['status'] ?? 'Session';
                        final DateTime time = activity['time'];
                        final formattedTime = FormatterUtils.formatTimeAgo(
                          time,
                        );

                        IconData icon;
                        if (status == 'completed' || status == 'attended') {
                          icon = Icons.check_circle;
                        } else if (status == 'confirmed') {
                          icon = Icons.schedule;
                        } else {
                          icon = Icons.info_outline;
                        }

                        return Column(
                          children: [
                            SingleChildScrollView(
                              child: ActivityCard(
                                icon: icon,
                                title: "$status session with $tutorName",
                                subtitle: "$subject • $formattedTime",
                                time: formattedTime,
                              ),
                            ),
                            Divider(height: 24, color: Colors.grey),
                          ],
                        );
                      }),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
