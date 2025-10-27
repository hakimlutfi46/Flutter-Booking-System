// lib/presentation/shared_features/register/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_booking_system/core/navigation/routes.dart';
import 'package:flutter_booking_system/presentation/shared_features/register/controllers/register.controller.dart';
import 'package:flutter_booking_system/presentation/widgets/auth_wrapper.dart';
import 'package:flutter_booking_system/presentation/widgets/primary_button.dart';
import 'package:get/get.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      title: "Create Account 🚀",
      subtitle: "Start your learning journey today",
      child: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name
            TextFormField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                hintText: "Enter your full name",
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? "Full name is required"
                          : null,
            ),
            const SizedBox(height: 20),

            // Email
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

            // Password
            Obx(
              () => TextFormField(
                controller: controller.passwordController,
                obscureText: controller.isPasswordHidden.value,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Create a password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordHidden.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: controller.isPasswordHidden.toggle,
                  ),
                ),
                validator: controller.validatePassword,
              ),
            ),
            const SizedBox(height: 20),

            // Role Dropdown
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.selectedRole.value,
                items: const [
                  DropdownMenuItem(value: 'parent', child: Text('Parent')),
                  DropdownMenuItem(value: 'tutor', child: Text('Tutor')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    controller.selectedRole.value = val;
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Select Role",
                  hintText: "Choose your role",
                  prefixIcon: Icon(Icons.people_outline),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Register Button
            Obx(
              () => PrimaryButton(
                text: "Create Account",
                isLoading: controller.authC.isLoading.value,
                onPressed: controller.register,
              ),
            ),

            const SizedBox(height: 24),

            // Divider
            const AuthDivider(),

            const SizedBox(height: 24),

            // Login Link
            AuthLinkText(
              question: "Already have an account? ",
              linkText: "Sign In",
              onTap: () => Get.offNamed(Routes.LOGIN),
            ),
          ],
        ),
      ),
    );
  }
}
