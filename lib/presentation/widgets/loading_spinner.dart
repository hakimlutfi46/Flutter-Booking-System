import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(      
      child: CircularProgressIndicator(color: Get.theme.primaryColor),
    );
  }
}
