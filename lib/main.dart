import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_booking_system/firebase_options.dart';
import 'package:flutter_booking_system/core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get.dart';
import 'presentation/global/auth_controller.dart';
import 'core/navigation/navigation.dart';
import 'core/navigation/routes.dart';

void main() async {
  await initializeDateFormatting('id_ID', null);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(AuthController(), permanent: true);

  var initialRoute = await Routes.initialRoute;
  runApp(Main(initialRoute));
}

class Main extends StatelessWidget {
  final String initialRoute;
  const Main(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: Nav.routes,

      theme: AppTheme.lightTheme,
    );
  }
}
