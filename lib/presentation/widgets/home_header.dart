import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';
import 'package:get/get.dart';

class HomeHeader extends StatelessWidget {
  final RxString? greetingNameRx; 
  final String? greetingName; 
  final String subtitle;
  final List<Widget> statsRow;

  const HomeHeader({
    super.key,
    this.greetingNameRx,
    this.greetingName,
    required this.subtitle,
    required this.statsRow,
  }) : assert(greetingNameRx != null || greetingName != null,
            'Harus salah satu diisi: greetingName atau greetingNameRx');

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background gradient
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

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting (support Rx)
                ObxOrDefaultText(
                  greetingNameRx: greetingNameRx,
                  greetingName: greetingName,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 40),

                // Stats
                ...statsRow,

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sub-widget untuk handle Obx atau static text
class ObxOrDefaultText extends StatelessWidget {
  final RxString? greetingNameRx;
  final String? greetingName;

  const ObxOrDefaultText({
    super.key,
    this.greetingNameRx,
    this.greetingName,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildText(String name) => RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Halo, ',
                style: Get.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: name,
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
        );

    // Jika reactive → pakai Obx
    if (greetingNameRx != null) {
      return Obx(() => buildText(greetingNameRx!.value));
    }

    // Jika statis → langsung tampilkan
    return buildText(greetingName ?? '');
  }
}
