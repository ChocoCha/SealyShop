import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/pages/bottomnav.dart';
import 'package:sealyshop/pages/signup.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email="", password="";
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey= GlobalKey<FormState>();

  userLogin()async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      Navigator.push(context, MaterialPageRoute(builder: (context)=> BottomNav() ));
    } on FirebaseAuthException catch(e){
      if(e.code=='user-not-found'){
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("No User Found for the Email",style: TextStyle(fontSize: 20.0),)));
      }
      else if(e.code=="wrong-password"){
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Wrong Password Provided by User",style: TextStyle(fontSize: 20.0),)));
      }
    }
  }
 

  @override
  Widget build(BuildContext context) {
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
                      "SIGN IN",
                      style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9458ED),
                      )
                    ),
                    
                    SizedBox(height: 30.0),
                    
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
                      child: TextFormField(
                        validator: (value){
                          if(value==null|| value.isEmpty){
                            return'Please enter your Email';
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
                      child: TextFormField(
                        validator: (value){
                          if(value==null|| value.isEmpty){
                            return'Please enter your Password';
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
                          
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20.0),
                    
                   
                    
                  
                    
                    // Login Button
                    GestureDetector(
                      onTap: (){
                        if(_formkey.currentState!.validate()){
                          setState(() {
                            email=mailcontroller.text;
                            password= passwordcontroller.text;
                          });
                        }
                        userLogin();
                      },
                      child: Center(
                        child: Container(
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
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUp()));
          
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

  @override
  void dispose() {
    
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
