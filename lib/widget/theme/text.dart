import 'package:flutter/material.dart';

class TextStyles {
  TextStyles._(); // Private constructor

  /// -- TextTheme สำหรับใช้งานในแอปพลิเคชัน
  // คุณสามารถเปลี่ยนชื่อตัวแปรนี้เป็นชื่อที่ต้องการได้ (เช่น lightTextTheme หรือ customTextTheme)
  static const TextTheme appTextTheme = TextTheme(
    // Headline
    headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
    headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600, color: Colors.black),
    headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.black),

    // Title
    titleLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.black),
    titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.black),
    titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: Colors.black),

    // Body
    bodyLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black),
    bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: Colors.black54),

    // Label
    labelLarge: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.black),
    labelMedium: TextStyle(fontSize: 10.0, fontWeight: FontWeight.normal, color: Colors.black54),
  );
}