import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppTextStyles {
  static TextStyle get h3Bold => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 20.sp,
    height: 1.3,
    letterSpacing: -0.01,
    color: Colors.white,
  );
  static TextStyle get h2Bold => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 12.sp,
    height: 1.3,
    letterSpacing: -0.01,
    color: Colors.white,
  );

  static TextStyle get bodyRegular => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w400,
    fontSize: 12.sp,
    color: Colors.white
  );
  static TextStyle get bodyRegularDark => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w400,
    fontSize: 14.sp,
  );

  static TextStyle get bodyBold => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w600,
    fontSize: 12.sp,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w400,
    fontSize: 10.sp,
  );
}
