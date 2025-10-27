import 'package:flutter/material.dart';
import 'package:flutter_booking_system/infrastructure/navigation/bindings/controllers/login.controller.binding.dart';
import 'package:flutter_booking_system/infrastructure/navigation/bindings/controllers/splash.controller.binding.dart';
import 'package:flutter_booking_system/presentation/login/controller/login.controller.dart';
import 'package:flutter_booking_system/presentation/login/login.screen.dart';
import 'package:flutter_booking_system/presentation/splash/splash.screen.dart';

import 'package:get/get.dart';

import '../../config.dart';
import '../../presentation/screens.dart';
import 'bindings/controllers/controllers_bindings.dart';
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
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeControllerBinding(),
    ),
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
  ];
}
