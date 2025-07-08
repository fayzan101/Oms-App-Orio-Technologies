import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'sign_in_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // For iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false, // ✅ Added this line
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF007AFF),
        body: Stack(
          children: [
            // Full Background Image (fills under status and nav bars)
            Positioned.fill(
              child: Image.asset(
                'assets/man.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            // Chart Image Overlay
            Positioned(
              left: mediaQuery.size.width * 0.10,
              top: mediaQuery.size.height * 0.47,
              child: Image.asset(
                'assets/chart.jpg',
                width: mediaQuery.size.width * 0.30,
                fit: BoxFit.contain,
              ),
            ),
            // Next Button at Bottom Center (inside SafeArea for padding only at bottom)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                minimum: EdgeInsets.only(bottom: mediaQuery.size.height * 0.03),
                top: false,
                left: false,
                right: false,
                child: SizedBox(
                  width: mediaQuery.size.width * 0.55,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => SignInScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontFamily: 'SFProDisplay',
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
