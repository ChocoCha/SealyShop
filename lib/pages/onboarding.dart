import 'package:flutter/material.dart';
import 'package:sealyshop/pages/login.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 238, 241),
      body: SafeArea(
        child: Stack(
          children: [
            // วงกลมตกแต่งด้านขวา
            Positioned(
              right: -100,
              top: 150,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color.fromARGB(255, 215, 166, 241).withOpacity(0.6),
                      Color.fromARGB(255, 190, 116, 210).withOpacity(0.2),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -80,
              top: 400,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFFFD6EC).withOpacity(0.5),
                      Color(0xFFFFD6EC).withOpacity(0.15),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // เนื้อหาหลัก
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo ด้านบนซ้าย
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Color(0xFF9C27B0),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      "images/app-icon.png",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: 40),

                // ข้อความหลัก
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ค้นพบ",
                        style: TextStyle(
                          color: Color(0xFF2D2D2D),
                          fontSize: 48.0,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        "เครื่องเขียน",
                        style: TextStyle(
                          color: Color(0xFF2D2D2D),
                          fontSize: 48.0,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        "คุณภาพดี",
                        style: TextStyle(
                          color: Color(0xFF2D2D2D),
                          fontSize: 48.0,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        "ที่สุด",
                        style: TextStyle(
                          color: Color(0xFF2D2D2D),
                          fontSize: 48.0,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 35),

                // รูปภาพ
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        "images/pen.jpg",
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40),

                // ปุ่ม Get Started
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LogIn()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 173, 17, 184),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        "เริ่มต้นใช้งาน",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}