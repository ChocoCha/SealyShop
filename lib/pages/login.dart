import 'dart:async'; // **ต้องเพิ่ม import นี้สำหรับ Timer**
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/Admin/admin_login.dart';
import 'package:sealyshop/pages/bottomnav.dart';
import 'package:sealyshop/pages/signup.dart';
import 'package:sealyshop/services/database.dart';
import 'package:sealyshop/services/shared_pref.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  // State สำหรับการจัดการ Login Lockout
  int _loginAttempts = 0;
  DateTime? _lockUntil;
  Timer? _lockTimer;

  String email = "", password = "";
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  // Getter สำหรับตรวจสอบว่าถูกล็อคอยู่หรือไม่
  bool get _isLocked {
    if (_lockUntil == null) return false;
    // ตรวจสอบว่าเวลาปัจจุบันยังไม่ถึงเวลาปลดล็อค
    return _lockUntil!.isAfter(DateTime.now());
  }

  // คำนวณเวลาที่เหลือสำหรับแสดงผลบน UI
  String _getLockMessage() {
    if (!_isLocked) return '';
    final remainingTime = _lockUntil!.difference(DateTime.now());
    // แสดงเวลาที่เหลือเป็นวินาที
    return 'Too many failed attempts. Try again in ${remainingTime.inSeconds.clamp(0, 30)} seconds.';
  }

  // เริ่มตัวจับเวลานับถอยหลัง
  void _startLockTimer() {
    // ยกเลิก Timer ตัวเก่าถ้ามี
    if (_lockTimer != null) _lockTimer!.cancel();

    _lockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_lockUntil == null || DateTime.now().isAfter(_lockUntil!)) {
        // เมื่อหมดเวลาล็อคแล้ว ให้ยกเลิก Timer
        timer.cancel();
        setState(() {
          _lockUntil = null; // ปลดล็อค
        });
      } else {
        // บังคับให้ UI build ใหม่ทุกวินาทีเพื่ออัพเดทเวลานับถอยหลัง
        setState(() {}); 
      }
    });
  }

  @override
  void dispose() {
    // ยกเลิก Timer เมื่อ Widget ถูกทำลาย
    _lockTimer?.cancel();
    super.dispose();
  }

  userLogin() async {
    // 1. **ตรวจสอบสถานะล็อค**
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orange,
          content:
              Text(_getLockMessage(), style: TextStyle(fontSize: 16.0))));
      return; // หยุดการทำงานถ้าถูกล็อค
    }

    try {
      // 2. Firebase Login
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      // LOGIN SUCCESSFUL: รีเซ็ตจำนวนครั้งที่พยายามผิดพลาด
      setState(() {
        _loginAttempts = 0;
        _lockUntil = null;
        _lockTimer?.cancel();
      });

      // 3. ดึงข้อมูลผู้ใช้ล่าสุดจาก Firestore
      DocumentSnapshot userDetails =
          await DatabaseMethod().getUserDetails(uid);
      Map<String, dynamic> data = userDetails.data() as Map<String, dynamic>;

      // 4. บันทึกข้อมูลโปรไฟล์ล่าสุดลง Shared Preferences
      await SharedPreferenceHelper().saveUserId(uid);
      await SharedPreferenceHelper().saveUserName(data['Name']);
      await SharedPreferenceHelper().saveUserEmail(data['Email']);
      await SharedPreferenceHelper()
          .saveUserImage(data['Image'] ?? ''); // บันทึกรูปโปรไฟล์
      await SharedPreferenceHelper()
          .saveUserAddress(data['Address'] ?? '');

      // 5. นำทางไปยังหน้าหลัก
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BottomNav()));
    } on FirebaseAuthException catch (e) {
      // LOGIN FAILED: เพิ่มจำนวนครั้งที่พยายามผิดพลาด
      setState(() {
        _loginAttempts++;
      });

      // **กลไก Lockout 30 วินาที**
      if (_loginAttempts >= 3 && !_isLocked) {
        final lockDuration = Duration(seconds: 30);
        setState(() {
          _lockUntil = DateTime.now().add(lockDuration);
        });
        _startLockTimer(); // เริ่มตัวจับเวลานับถอยหลัง
      }

      // แสดง error message
      String message;
      if (e.code == 'user-not-found') {
        message = "No User Found for the Email";
      } else if (e.code == "wrong-password") {
        message = "Wrong Password Provided by User";
      } else {
        message = "An unexpected error occurred: ${e.code}";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(message, style: TextStyle(fontSize: 16.0))));
    }
  }

  @override
  Widget build(BuildContext context) {
    // คำนวณสีสำหรับปุ่ม Login
    final loginButtonGradient = _isLocked
        ? LinearGradient(
            colors: [Colors.grey.shade400, Colors.grey.shade600])
        : LinearGradient(
            colors: [Color(0xFFFF80D3), Color(0xFF9458ED)],
          );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              // Header Section with Curved Bottom
              ClipPath(
                clipper: CurvedBottomClipper(),
                child: Container(
                  height: 350,
                  decoration: BoxDecoration(),
                  child: Stack(
                    children: [
                      // GIF Background
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            "images/login4.gif",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.0),

                    // Sign In Title
                    Text("SIGN IN",
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9458ED),
                        )),

                    SizedBox(height: 30.0),

                    // Email Field
                    Text("Email",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6D6D6D),
                        )),
                    SizedBox(height: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Email';
                          }
                          return null;
                        },
                        controller: mailcontroller,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: 16.0),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "demo@email.com",
                          hintStyle: TextStyle(
                            color: Color(0xFFBDBDBD),
                            fontSize: 15.0,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Color(0xFF9E9E9E),
                            size: 20,
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 15.0),
                        ),
                      ),
                    ),

                    SizedBox(height: 25.0),

                    // Password Field
                    Text("Password",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6D6D6D),
                        )),
                    SizedBox(height: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: TextFormField(
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Password';
                          }
                          return null;
                        },
                        controller: passwordcontroller,
                        style: TextStyle(fontSize: 16.0),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "enter your password",
                          hintStyle: TextStyle(
                            color: Color(0xFFBDBDBD),
                            fontSize: 15.0,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Color(0xFF9E9E9E),
                            size: 20,
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 15.0),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.0),

                    // **แสดงข้อความล็อคเมื่อมีการล็อคเกิดขึ้น**
                    if (_isLocked)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          _getLockMessage(),
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    
                    // Login Button
                    GestureDetector(
                      // **ปิดใช้งานปุ่ม Login หากถูกล็อค**
                      onTap: _isLocked
                          ? null
                          : () {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = mailcontroller.text;
                                  password = passwordcontroller.text;
                                });
                                userLogin();
                              }
                            },
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            // **เปลี่ยนสีปุ่มเมื่อถูกล็อค**
                            gradient: loginButtonGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: _isLocked
                                    ? Colors.transparent
                                    : Color(0xFF9458ED).withOpacity(0.4),
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              // กำหนดสี splash ให้เหมาะสมกับสถานะ locked/unlocked
                              splashColor: _isLocked ? Colors.transparent : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(28),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 25.0),

                    // Sign Up Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an Account ? ",
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 14.0,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUp()));
                            },
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                color: Color(0xFF9458ED),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    // Admin Login Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "LOGIN AS ADMIN ?",
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 14.0,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AdminLogin()));
                            },
                            child: Text(
                              "Admin",
                              style: TextStyle(
                                color: Color(0xFF9458ED),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Clipper for Curved Bottom (ไม่เปลี่ยนแปลง)
class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // เริ่มจากมุมซ้ายบน
    path.lineTo(0, size.height - 100);

    // โค้งนุ่ม ๆ จากซ้ายไปขวา
    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.5, size.height - 40);

    var secondControlPoint = Offset(size.width * 0.75, size.height - 120);
    var secondEndPoint = Offset(size.width, size.height - 60);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    // ปิด path ด้านขวาและด้านบน
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
