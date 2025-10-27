// lib/presentation/shared_features/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/navigation/routes.dart';
import 'package:flutter_booking_system/core/theme/app_colors.dart';
import 'package:flutter_booking_system/presentation/shared_features/login/controller/login.controller.dart';
import 'package:flutter_booking_system/presentation/widgets/auth_wrapper.dart';
import 'package:flutter_booking_system/presentation/widgets/primary_button.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      title: "Welcome Back! 👋",
      subtitle: "Sign in to continue your learning journey",
      child: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field
            TextFormField(
              controller: controller.emailController,
              decoration: const InputDecoration(
                labelText: "Email Address",
                hintText: "Enter your email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
            ),
            const SizedBox(height: 20),

            // Password Field
            Obx(
              () => TextFormField(
                controller: controller.passwordController,
                obscureText: controller.isPasswordHidden.value,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordHidden.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      controller.isPasswordHidden.toggle();
                    },
                  ),
                ),
                validator: controller.validatePassword,
              ),
            ),

            const SizedBox(height: 12),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Add forgot password logic
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "Forgot Password?",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Login Button
            Obx(
              () => PrimaryButton(
                text: "Sign In",
                isLoading: controller.authC.isLoading.value,
                onPressed: () => controller.login(),
              ),
            ),

            const SizedBox(height: 24),

            // Divider
            const AuthDivider(),

            const SizedBox(height: 24),

            // Register Link
            AuthLinkText(
              question: "Don't have an account? ",
              linkText: "Register",
              onTap: () => Get.offNamed(Routes.REGISTER),
            ),
          ],
        ),
      ),
    );
  }
}
