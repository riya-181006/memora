import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color bgDark = Color(0xFF1A0B2E);
  static const Color bgMid = Color(0xFF5B2A86);
  static const Color bgEnd = Color(0xFFB83280);

  static const Color primary = Color(0xFFEC4899);
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color accent = Color(0xFFFFB86C);

  static const Color textPrimary = Color(0xFFFFF1F5);
  static const Color textSecondary = Color(0xB3FFFFFF);

  static const Color glassFill = Color(0x24FFFFFF);
  static const Color glassFillStrong = Color(0x38FFFFFF);
  static const Color glassBorder = Color(0x4DFFFFFF);

  static const Color blobPink = Color(0x80FF6B9D);
  static const Color blobOrange = Color(0x66FFB86C);

  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFF87171);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgDark, bgMid, bgEnd],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primary, secondary],
  );
}