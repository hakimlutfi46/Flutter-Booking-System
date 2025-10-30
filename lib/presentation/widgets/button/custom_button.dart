import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color? color;
  final IconData? icon;
  final String iconPosition; // 'before' | 'after'
  final VoidCallback onTap;
  final bool isOutlined; // 🔲 false = filled, true = outlined

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
    this.icon,
    this.iconPosition = 'before',
    this.isOutlined = true, // default outline
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = color ?? AppColors.primary;

    final Color backgroundColor =
        isOutlined ? baseColor.withOpacity(0.1) : baseColor;
    final Color borderColor =
        isOutlined ? baseColor.withOpacity(0.3) : Colors.transparent;
    final Color textColor = isOutlined ? baseColor : Colors.white;

    List<Widget> buildContent() {
      final textWidget = Text(
        text,
        style: Get.textTheme.titleMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      );

      if (icon == null) return [textWidget];

      final iconWidget = Icon(icon, color: textColor);

      return iconPosition == 'after'
          ? [textWidget, const SizedBox(width: 12), iconWidget]
          : [iconWidget, const SizedBox(width: 12), textWidget];
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildContent(),
          ),
        ),
      ),
    );
  }
}
