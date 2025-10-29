import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/navigation/middleware/auth_guard.dart';
import 'package:flutter_booking_system/core/navigation/middleware/role_guard.dart';
import 'package:flutter_booking_system/presentation/parent_features/search_tutors/binding/search_tutor.binding.dart';
import 'package:flutter_booking_system/presentation/parent_features/search_tutors/views/search_tutor.screen.dart';
import 'package:flutter_booking_system/presentation/parent_features/tutor_detail/binding/tutor_detail.binding.dart';
import 'package:flutter_booking_system/presentation/parent_features/tutor_detail/views/tutor_detail.screen.dart';
import 'package:flutter_booking_system/presentation/shared_features/dashboard/bindings/dashboard.binding.dart';
import 'package:flutter_booking_system/presentation/shared_features/dashboard/views/dashboard.screen.dart';
import 'package:flutter_booking_system/presentation/shared_features/login/bindings/login.controller.binding.dart';
import 'package:flutter_booking_system/presentation/shared_features/login/views/login.screen.dart';
import 'package:flutter_booking_system/presentation/shared_features/profile/bindings/profile.binding.dart';
import 'package:flutter_booking_system/presentation/shared_features/profile/views/profile.screen.dart';
import 'package:flutter_booking_system/presentation/shared_features/register/bindings/register.binding.dart';
import 'package:flutter_booking_system/presentation/shared_features/register/views/register.screen.dart';
import 'package:flutter_booking_system/presentation/shared_features/splash/bindings/splash.controller.binding.dart';
import 'package:flutter_booking_system/presentation/shared_features/splash/splash.screen.dart';

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
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
      binding: RegsiterBiding(),
    ),

    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthGuard()],
    ),

    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
      middlewares: [AuthGuard()],
    ),

    GetPage(
      name: Routes.SEARCH_TUTOR,
      page: () => SearchTutorScreen(),
      binding: SearchTutorBinding(),
      middlewares: [
        AuthGuard(),
        RoleGuard(['parent']),
      ],
    ),

    GetPage(
      name: Routes.TUTOR_DETAIL,
      page: () => TutorDetailScreen(),
      binding: TutorDetailBinding(),
      middlewares: [
        AuthGuard(),
        RoleGuard(['parent']),
      ],
    ),
  ];
}
