import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_in_screen.dart';

class ResetPasswordController extends GetxController {
  var obscurePassword = true.obs;
  var obscureConfirm = true.obs;
}

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({Key? key}) : super(key: key);
  final ResetPasswordController controller = Get.put(ResetPasswordController());

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    double blockH = height / 100;
    double blockW = width / 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: blockW * 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: blockH * 2),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F0FF),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_outline,
                        color: Color(0xFF007AFF),
                        size: 56,
                      ),
                    ),
                  ),
                  SizedBox(height: blockH * 4),
                  Text(
                    'Forgot Password',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: blockW * 7.2,
                      color: Color(0xFF183046),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: blockH * 3),
                  Obx(() => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(blockW * 2),
                    ),
                    child: TextField(
                      obscureText: controller.obscurePassword.value,
                      decoration: InputDecoration(
                        hintText: 'Enter Password',
                        hintStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: blockW * 4.1,
                          color: const Color(0xFF6B6B6B),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: blockW * 4, vertical: 12),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFFBDBDBD),
                          ),
                          onPressed: () => controller.obscurePassword.value = !controller.obscurePassword.value,
                        ),
                      ),
                    ),
                  )),
                  SizedBox(height: blockH * 2),
                  Obx(() => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(blockW * 2),
                    ),
                    child: TextField(
                      obscureText: controller.obscureConfirm.value,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        hintStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: blockW * 4.1,
                          color: const Color(0xFF6B6B6B),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: blockW * 4, vertical: 12),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscureConfirm.value ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFFBDBDBD),
                          ),
                          onPressed: () => controller.obscureConfirm.value = !controller.obscureConfirm.value,
                        ),
                      ),
                    ),
                  )),
                  SizedBox(height: blockH * 3),
                  SizedBox(
                    height: blockH * 6.2,
                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 0),
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(28),
                                    topRight: Radius.circular(28),
                                  ),
                                ),
                                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE6F0FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.check,
                                          color: Color(0xFF007AFF),
                                          size: 56,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Success!',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                        color: Color(0xFF183046),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your password has been changed',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        color: Color(0xFF222222),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF007AFF),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          'Ok',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(blockW * 2),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Reset',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: blockW * 4.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: blockH * 3.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: blockW * 3.6,
                          color: const Color(0xFF6B6B6B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(() => SignInScreen()),
                        child: Text(
                          'Click here to Sign In',
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
      ),
    );
  }
} 