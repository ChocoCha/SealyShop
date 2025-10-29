import 'package:flutter/material.dart';
import 'package:sealyshop/pages/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}



class _SignUpState extends State<SignUp> {
  final bool _isPasswordVisible = false;
  final bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Curved Bottom
            ClipPath(
              clipper: CurvedBottomClipper(),
              child: Container(
                height: 350,
                decoration: BoxDecoration(
                  
                ),
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
                    // Center Logo
                    
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
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  
                  SizedBox(height: 30.0),

                  // Name Label
                  Text(
                    "Name",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6D6D6D),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  
                  // Name Field
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 16.0),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "your name",
                        hintStyle: TextStyle(
                          color: Color(0xFFBDBDBD),
                          fontSize: 15.0,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outlined,
                          color: Color(0xFF9E9E9E),
                          size: 20,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 25.0),
                  
                  
                  // Email Label
                  Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6D6D6D),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  
                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: _emailController,
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
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 25.0),
                  
                  // Password Label
                  Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6D6D6D),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  
                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
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
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Color(0xFF9E9E9E),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              
                            });
                          },
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20.0),
                  
                  // Remember Me and Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  
                                });
                              },
                              activeColor: Color(0xFFFF80D3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Remember Me",
                            style: TextStyle(
                              fontSize: 13.0,
                              color: Color(0xFF6D6D6D),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Forget Password?",
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Color(0xFF9458ED),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 40.0),
                  
                  // Login Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF80D3),
                          Color(0xFF9458ED),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF9458ED).withOpacity(0.4),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () {
                          // Login logic
                        },
                        child: Center(
                          child: Text(
                            "SIGNUP",
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
                  
                  SizedBox(height: 25.0),
                  
                  // Sign Up Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account ? ",
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 14.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> LogIn()));
                          },
                          child: Text(
                              "Sign in",
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Custom Clipper for Curved Bottom
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
