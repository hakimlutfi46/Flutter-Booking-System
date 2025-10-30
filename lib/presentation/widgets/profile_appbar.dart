import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';
import 'package:flutter_booking_system/core/utils/formatter_utils.dart';
import 'package:get/get.dart';

class ProfileAppbar extends StatelessWidget {
  final String name, role;

  const ProfileAppbar({super.key, required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // Hitung progress collapse (0.0 = expanded, 1.0 = collapsed)
          final double progress =
              (constraints.maxHeight - kToolbarHeight) / (200 - kToolbarHeight);
          final bool isCollapsed = progress < 0.3;

          return FlexibleSpaceBar(
            titlePadding: EdgeInsets.zero,
            centerTitle: true,
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isCollapsed ? 1.0 : 0.0,
              child: Container(
                height: kToolbarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Avatar kecil
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.secondary.withOpacity(0.2),
                        child: Text(
                          FormatterUtils.getInitials(name),
                          style: Get.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nama dan Role
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Get.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            FormatterUtils.getRoleName(role),
                            style: Get.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark.withOpacity(0.8),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            background: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isCollapsed ? 0.0 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar besar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColors.secondary.withOpacity(0.2),
                        child: Text(
                          FormatterUtils.getInitials(name),
                          style: Get.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        FormatterUtils.getRoleName(role),
                        style: Get.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
