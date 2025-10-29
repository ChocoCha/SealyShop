import 'package:flutter/material.dart';

class AppWidget {
  static TextStyle boldTextFeildStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Nunito',  // เปลี่ยนเป็น Nunito
    );
  }

  static TextStyle lightTextFeildStyle() {
    return TextStyle(
      color: Colors.black54,
      fontSize: 15.0,
      fontWeight: FontWeight.w400,
      fontFamily: 'Nunito',  // เปลี่ยนเป็น Nunito
    );
  }

  static TextStyle semiboldTextFeildStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      fontFamily: 'Nunito',  // เปลี่ยนเป็น Nunito
    );
  }

  static TextStyle mediumTextFeildStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      fontFamily: 'Nunito',  // เปลี่ยนเป็น Nunito
    );
  }
}