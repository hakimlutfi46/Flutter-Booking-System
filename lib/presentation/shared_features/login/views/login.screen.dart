// lib/presentation/login/login.screen.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controller/login.controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: controller.validatePassword,
              ),
              const SizedBox(height: 30),
              Obx(
                () => ElevatedButton(
                  onPressed: () {
                    controller.login();
                  },
                  child: Text(
                    controller.authC.isLoading.isFalse ? "LOGIN" : "LOADING...",
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Obx(
              //   () => TextButton(
              //     onPressed: () {
              //       controller.register();
              //     },
              //     child: Text(
              //       controller.authC.isLoading.isFalse
              //           ? "REGISTER"
              //           : "LOADING...",
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
