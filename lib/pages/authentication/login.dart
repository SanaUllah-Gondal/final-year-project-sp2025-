import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  final Color darkBlue = const Color(0xFF003E6B);
  final Color tealBlue = const Color(0xFF00A8A8);

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Skill-Link',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [darkBlue, tealBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    const Icon(Icons.lock, size: 80, color: Colors.black),
                    const SizedBox(height: 20),

                    // ✅ Email Field
                    TextFormField(
                      controller: controller.emailController,
                      validator: controller.validateEmail,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // ✅ Password Field
                    TextFormField(
                      controller: controller.passwordController,
                      validator: controller.validatePassword,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),

                    // ✅ Remember Me
                    Obx(() => CheckboxListTile(
                      value: controller.rememberMe.value,
                      onChanged: (bool? value) {
                        controller.toggleRememberMe(value ?? false);
                      },
                      title: const Text(
                        "Remember Me",
                        style: TextStyle(color: Colors.white),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    )),
                    const SizedBox(height: 20),

                    // ✅ Login Button
                    Obx(() => ElevatedButton(
                      onPressed:
                      controller.isLoading.value ? null : controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCD00),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    )),
                    const SizedBox(height: 20),

                    // ✅ Signup Redirect
                    TextButton(
                      onPressed: controller.navigateToSignup,
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
