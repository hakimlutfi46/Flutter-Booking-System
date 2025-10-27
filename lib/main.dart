import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_booking_system/firebase_options.dart';

import 'package:get/get.dart';

import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var initialRoute = await Routes.initialRoute;
  runApp(Main(initialRoute));  
}

class Main extends StatelessWidget {
  final String initialRoute;  
  const Main(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(initialRoute: initialRoute, getPages: Nav.routes);    
  }
}
