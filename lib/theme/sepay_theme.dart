import 'package:flutter/material.dart';

/// Màu thương hiệu SePay (tham chiếu giao diện my.sepay.vn)
abstract final class SepayTheme {
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryDark = Color(0xFF0047B3);
  static const Color accent = Color(0xFFFF6B00);
  static const Color accentLight = Color(0xFFFFF3E8);
  static const Color success = Color(0xFF00A86B);
  static const Color surface = Color(0xFFF4F6FB);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF007A4D), success],
  );
}
