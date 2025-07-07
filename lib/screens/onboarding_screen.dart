import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'sign_in_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Transparent Status Bar & Navigation Bar (Immersive Look)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents layout shifting
      extendBody: true, // Allows content under navigation bar
      extendBodyBehindAppBar: true, // Allows content under status bar
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ✅ Full Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/man.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Chart Image Overlay (Positioned Responsively)
          Positioned(
            left: mediaQuery.size.width * 0.10,
            top: mediaQuery.size.height * 0.47,
            child: Image.asset(
              'assets/chart.jpg',
              width: mediaQuery.size.width * 0.30,
              fit: BoxFit.contain,
            ),
          ),

          // ✅ Next Button at Bottom Center (Inside SafeArea for Padding)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: EdgeInsets.only(bottom: mediaQuery.size.height * 0.03),
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
    );
  }
}
