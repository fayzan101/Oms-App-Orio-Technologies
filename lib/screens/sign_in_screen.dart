import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'create_account_screen.dart';
import 'forgot_password_screen.dart';

class SignInController extends GetxController {
  var obscurePassword = true.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = Get.find<AuthService>();

  // Error states for input fields
  final emailError = false.obs;
  final passwordError = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> signIn() async {
    // Dismiss keyboard
    Get.focusScope?.unfocus();
    emailError.value = false;
    passwordError.value = false;

    final email = emailController.text.trim();
    final password = passwordController.text;

    // Simple email validation
    final emailValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(email);
    if (email.isEmpty || password.isEmpty || !emailValid) {
      emailError.value = true;
      passwordError.value = true;
      Get.snackbar(
        'Invalid',
        'Invalid email or password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final success = await authService.login(email, password);

    if (success) {
      // Show success snackbar on dashboard
      Get.offAllNamed('/dashboard');
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      });
    } else {
      emailError.value = true;
      passwordError.value = true;
      Get.snackbar(
        'Invalid',
        'Invalid email or password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}

class SignInScreen extends StatelessWidget {
  SignInScreen({Key? key}) : super(key: key);
  final SignInController controller = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    // Responsive scaling factors
    double blockH = height / 100;
    double blockW = width / 100;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: blockW * 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: blockH * 14), // Increased top margin for more downward shift
                Text(
                  'Sign In',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: blockW * 8.2, // ~32 on 390px
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: blockH * 1.2),
                Text(
                  "and let's get those orders moving!",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: blockW * 3.8,
                    color: Colors.black // darker subtitle
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: blockH * 5.2),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(blockW * 2), // 8 on 390px
                    border: controller.emailError.value
                        ? Border.all(color: Colors.red, width: 1.5)
                        : null,
                  ),
                  child: TextField(
                    controller: controller.emailController,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: blockW * 4.1,
                      color: Colors.black, // darker input text
                    ),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: blockW * 4.1, // ~16 on 390px
                        color: Colors.black, // darker hint
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: blockW * 4, vertical: blockH * 2.2),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(height: blockH * 2),
                Obx(() => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(blockW * 2),
                    border: controller.passwordError.value
                        ? Border.all(color: Colors.red, width: 1.5)
                        : null,
                  ),
                  child: TextField(
                    controller: controller.passwordController,
                    obscureText: controller.obscurePassword.value,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: blockW * 4.1,
                      color: Colors.black, // darker input text
                    ),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: blockW * 4.1,
                        color: Colors.black, // darker hint
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: blockW * 4, vertical: blockH * 2.2),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black, // darker icon
                          size: blockW * 6,
                        ),
                        onPressed: () => controller.obscurePassword.value = !controller.obscurePassword.value,
                      ),
                    ),
                  ),
                )),
                SizedBox(height: blockH * 1.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.to(() => const ForgotPasswordScreen());
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerRight,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: blockW * 3.6, // ~14 on 390px
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: blockH * 1.1),
                Obx(() => SizedBox(
                  height: blockH * 6.2, // 48 on 777px
                  child: ElevatedButton(
                    onPressed: controller.authService.isLoading.value ? null : controller.signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(blockW * 2),
                      ),
                      elevation: 0,
                    ),
                    child: controller.authService.isLoading.value
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Sign in',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: blockW * 4.4, // ~17 on 390px
                              color: Colors.white,
                            ),
                          ),
                  ),
                )),
                SizedBox(height: blockH * 3.1),
                Row(
                  children: [
                    Expanded(child: Divider(thickness: 1, color: const Color(0xFFE0E0E0))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: blockW * 2),
                      child: Text(
                        'OR',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: blockW * 3.8, // ~15 on 390px
                          color: const Color(0xFF6B6B6B),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(thickness: 1, color: const Color(0xFFE0E0E0))),
                  ],
                ),
                SizedBox(height: blockH * 3.1),
                // Center Google and Facebook buttons
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: blockH * 6.2,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/icon/google.png',
                            height: blockW * 5.6, // ~22 on 390px
                            width: blockW * 5.6,
                          ),
                          label: Text(
                            'Continue with Google',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: blockW * 4.1, // ~16 on 390px
                              color: const Color(0xFF222222),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F3F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(blockW * 2),
                            ),
                            elevation: 0,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: blockW * 4),
                          ),
                        ),
                      ),
                      SizedBox(height: blockH * 1.6),
                      SizedBox(
                        height: blockH * 6.2,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/icon/facebook.png',
                            height: blockW * 5.6,
                            width: blockW * 5.6,
                          ),
                          label: Text(
                            'Continue with Facebook',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: blockW * 4.1,
                              color: const Color(0xFF222222),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F3F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(blockW * 2),
                            ),
                            elevation: 0,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: blockW * 4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: blockH * 4.2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: blockW * 3.6, // ~14 on 390px
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => CreateAccountScreen()),
                      child: Text(
                        'Create an Account',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: blockW * 3.6,
                          color: const Color(0xFF007AFF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: blockH * 2.2),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 