import 'package:flutter/widgets.dart';
import 'package:flutter_booking_system/presentation/global/auth_controller.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final AuthController authC = Get.find<AuthController>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final selectedRole = "parent".obs;
  final isPasswordHidden = true.obs;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email cannot be empty';
    if (!GetUtils.isEmail(value)) return 'Invalid email format';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';
    if (value.length < 6) return 'Password must be at least 6 characters long';
    return null;
  }

  void register() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    authC.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      selectedRole.value,
    );
  }
}
