// lib/presentation/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final IconData? icon;

  const AuthWrapper({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            _buildDecorativeCircle(
              top: -50,
              right: -50,
              size: 200,
              opacity: 0.1,
            ),
            _buildDecorativeCircle(
              bottom: -80,
              left: -80,
              size: 250,
              opacity: 0.08,
            ),
            _buildDecorativeCircle(
              top: size.height * 0.2,
              right: -30,
              size: 100,
              opacity: 0.06,
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.06),

                      // Logo / Title Section with Animation
                      _AnimatedHeader(icon: icon),

                      SizedBox(height: size.height * 0.04),

                      // Auth Card with Animation
                      _AnimatedCard(
                        title: title,
                        subtitle: subtitle,
                        child: child,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }
}

/// Animated header component untuk logo dan title
class _AnimatedHeader extends StatelessWidget {
  final IconData? icon;

  const _AnimatedHeader({this.icon});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              icon ?? Icons.school_rounded,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Learning Apps",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Booking System",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated card component untuk form container
class _AnimatedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _AnimatedCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 900),
      tween: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero),
      curve: Curves.easeOutCubic,
      builder: (context, Offset offset, child) {
        return Transform.translate(
          offset: Offset(0, offset.dy * 100),
          child: Opacity(
            opacity: (1 - offset.dy / 0.3).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            child,
          ],
        ),
      ),
    );
  }
}

/// Widget helper untuk divider dengan text di tengah
class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({super.key, this.text = "or"});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }
}

/// Widget helper untuk link text (Register/Login)
class AuthLinkText extends StatelessWidget {
  final String question;
  final String linkText;
  final VoidCallback onTap;

  const AuthLinkText({
    super.key,
    required this.question,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
