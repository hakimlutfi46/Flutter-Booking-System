// lib/presentation/shared_features/profile/views/profile.screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';
import 'package:flutter_booking_system/core/utils/formatter_utils.dart';
import 'package:flutter_booking_system/presentation/shared_features/profile/controllers/profile.controller.dart';
import 'package:flutter_booking_system/presentation/widgets/button/custom_button.dart';
import 'package:flutter_booking_system/presentation/widgets/card/personal_info_card.dart';
import 'package:flutter_booking_system/presentation/widgets/card/quick_access_card.dart';
import 'package:flutter_booking_system/presentation/widgets/card/stat_card.dart';
import 'package:flutter_booking_system/presentation/widgets/loading_spinner.dart';
import 'package:flutter_booking_system/presentation/widgets/profile_appbar.dart';
import 'package:flutter_booking_system/presentation/widgets/snackbar/app_snackbar.dart';
import 'package:get/get.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.user == null) {
          return const LoadingSpinner();
        }

        final user = controller.user!;

        return CustomScrollView(
          slivers: [
            ProfileAppbar(
              name: controller.user!.name ?? "User",
              role: controller.user!.role,
            ),

            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Personal Information Section
                  Text(
                    "Informasi Personal",
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  PersonalInfoCard(
                    icon: Icons.person_outline,
                    iconColor: AppColors.primary,
                    label: "Full Name",
                    value: controller.user?.name ?? "Belum diatur",
                  ),

                  const SizedBox(height: 12),
                  PersonalInfoCard(
                    icon: Icons.email_outlined,
                    iconColor: AppColors.secondary,
                    label: "Email Address",
                    value: controller.user!.email,
                  ),
                  const SizedBox(height: 12),
                  PersonalInfoCard(
                    icon: Icons.verified_user_outlined,
                    iconColor: Colors.blue,
                    label: "Account Type",
                    value: FormatterUtils.getRoleName(controller.user!.role),
                  ),

                  const SizedBox(height: 32),

                  if (user.role == 'tutor') ...[
                    Text(
                      "Statistik Tutor",
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Obx(() {
                      if (controller.isLoadingStats.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.event_available_outlined,
                              label: "Sesi Selesai",
                              value: controller.totalSessions.value.toString(),
                              color: Colors.green.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: Icons.star_border_outlined,
                              label: "Rating Tutor",
                              value: controller.tutorRating.value
                                  .toStringAsFixed(1),
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 32),
                  ],

                  Text(
                    "Settings",
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  QuickAccessCard(
                    icon: Icons.edit_outlined,
                    iconColor: Colors.orange,
                    title: "Edit Profile",
                    subtitle: "Update your personal information",
                    onTap:
                        () => AppSnackbar.show(
                          title: "Coming Soon",
                          message:
                              "Edit profile feature will be available soon",
                          type: SnackbarType.neutral,
                          position: SnackPosition.TOP,
                        ),
                  ),
                  const SizedBox(height: 12),
                  QuickAccessCard(
                    icon: Icons.lock_outline,
                    iconColor: Colors.purple,
                    title: "Change Password",
                    subtitle: "Update your account password",
                    onTap:
                        () => AppSnackbar.show(
                          title: "Coming Soon",
                          message:
                              "Change password feature will be available soon",
                          type: SnackbarType.neutral,
                          position: SnackPosition.TOP,
                        ),
                  ),
                  const SizedBox(height: 12),

                  QuickAccessCard(
                    icon: Icons.notifications_outlined,
                    iconColor: Colors.blue,
                    title: "Notifications",
                    subtitle: "Manage notification preferences",
                    onTap:
                        () => AppSnackbar.show(
                          title: "Coming Soon",
                          message:
                              "Notification settings will be available soon",
                          type: SnackbarType.neutral,
                          position: SnackPosition.TOP,
                        ),
                  ),

                  const SizedBox(height: 32),

                  CustomButton(
                    text: "Logout",
                    color: AppColors.error,
                    icon: Icons.logout,
                    isOutlined: true,
                    onTap: controller.logoutWithConfirmation,
                  ),

                  const SizedBox(height: 16),

                  // App Version
                  Center(
                    child: Text(
                      "Version 1.0.0",
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }
}
