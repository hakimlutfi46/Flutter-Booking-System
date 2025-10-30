import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/splash.controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      backgroundColor: Get.theme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [            
            Container(
              width: 120, 
              height: 120,
              decoration: BoxDecoration(                
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.school_rounded,
                size: 80,
                color: Get.theme.primaryColor,
              ),
            ),
            const SizedBox(height: 48),

            const CircularProgressIndicator(color: Colors.white),

            const SizedBox(height: 24),

            Text(
              "Loading...",
              style: Get.textTheme.titleMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
