import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorResources {
  static const appMainColor = Color(0xffBA0C2F);
  static const whiteColor = Color(0xffFFFFFF);
  static const blackColor = Color(0xff000000);
  static const greyColor = Color(0xff474747);
  static const textfeildColor = Color(0xffF3F2F2);
  static const blueColor = Color(0xff1565FF);
  static const greenColor = Color(0xff0CBA97);
  static const gradientPurple = Color(0xFF4B134F);
  static const gradientRed = Color(0xFFBA0C2F);

  static LinearGradient get appBarGradient => const LinearGradient(
        colors: [gradientPurple, gradientRed],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static SystemUiOverlayStyle getSystemUiOverlayStyle() {
    return const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarColor: appMainColor,
      statusBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }

  static SystemUiOverlayStyle getSystemUiOverlayAllPages() {
    return const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: whiteColor,
      statusBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }
}
