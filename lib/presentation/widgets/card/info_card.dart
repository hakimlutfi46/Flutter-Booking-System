import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool showChevron;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon dengan gradient background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (iconColor ?? Get.theme.primaryColor).withOpacity(0.15),
                        (iconColor ?? Get.theme.primaryColor).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    leadingIcon,
                    color: iconColor ?? Get.theme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Trailing widget atau chevron
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing!,
                ] else if (showChevron && onTap != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
