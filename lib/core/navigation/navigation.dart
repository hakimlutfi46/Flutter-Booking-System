import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/navigation/middleware/auth_guard.dart';
import 'package:flutter_booking_system/core/navigation/middleware/role_guard.dart';
import 'package:flutter_booking_system/presentation/parent_features/dashboard/bindings/parent_dashboard.binding.dart';
import 'package:flutter_booking_system/presentation/parent_features/dashboard/views/parent_dashboard.screen.dart';
import 'package:flutter_booking_system/presentation/shared_features/login/bindings/login.controller.binding.dart';
import 'package:flutter_booking_system/presentation/shared_features/login/controller/login.controller.dart';
import 'package:flutter_booking_system/presentation/shared_features/login/views/login.screen.dart';
import 'package:flutter_booking_system/presentation/shared_features/splash/bindings/splash.controller.binding.dart';
import 'package:flutter_booking_system/presentation/shared_features/splash/splash.screen.dart';
import 'package:flutter_booking_system/presentation/tutor_features/dashboard/bindings/tutor_dashboard.binding.dart';
import 'package:flutter_booking_system/presentation/tutor_features/dashboard/views/tutor_dashboard.screen.dart';

import 'package:get/get.dart';

import '../../config.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  const EnvironmentsBadge({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    var env = ConfigEnvironments.getEnvironments()['env'];
    return env != Environments.PRODUCTION
        ? Banner(
          location: BannerLocation.topStart,
          message: env!,
          color: env == Environments.QAS ? Colors.blue : Colors.purple,
          child: child,
        )
        : SizedBox(child: child);
  }
}

class Nav {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashControllerBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginControllerBinding(),
    ),

    GetPage(
      name: Routes.PARENT_DASHBOARD,
      page: () => ParentDashboardScreen(),
      binding: ParentDashboardBinding(),
      middlewares: [
        AuthGuard(),
        RoleGuard(['parent']),
      ],
    ),

    GetPage(
      name: Routes.TUTOR_DASHBOARD,
      page: () => TutorDashboardScreen(),
      binding: TutorDashboardBinding(),
      middlewares: [
        AuthGuard(),
        RoleGuard(['tutor']),
      ],
    ),
  ];
}
