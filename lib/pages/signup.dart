import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:sealyshop/pages/bottomnav.dart';
import 'package:sealyshop/pages/login.dart';
import 'package:sealyshop/services/database.dart';
import 'package:sealyshop/services/shared_pref.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}



class _SignUpState extends State<SignUp> {
  String? name, email, password;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey= GlobalKey<FormState>();

  registration()async{
  if(_formkey.currentState!.validate()){
    setState(() {
      name = namecontroller.text;
      email = mailcontroller.text;
      password = passwordcontroller.text;
    });
    
    // 💡 URL ภาพ Default
    const String defaultImageUrl = "https://cdn-icons-png.freepik.com/512/9368/9368284.png";

    try{
      // 1. สร้าง User ด้วย Firebase Auth
      UserCredential userCredential= await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email!, password: password!);
      
      // ⭐️ FIX 1: ดึง UID จริงจาก UserCredential
      String trueUid = userCredential.user!.uid; 
      
      // 2. บันทึก UID จริงลงใน Shared Prefs
      await SharedPreferenceHelper().saveUserEmail(mailcontroller.text);
      await SharedPreferenceHelper().saveUserId(trueUid); // 🎯 FIX: ใช้ trueUid
      await SharedPreferenceHelper().saveUserName(namecontroller.text);
      await SharedPreferenceHelper().saveUserImage(defaultImageUrl); // บันทึกรูปภาพ Default
      await SharedPreferenceHelper().saveUserAddress(""); // 💡 NEW: บันทึก Address ว่าง

      // 3. เตรียม Map ข้อมูลที่ถูกต้อง
      Map<String, dynamic> userInfoMap={
        "Name" : namecontroller.text,
        "Email" : mailcontroller.text,
        "Id" : trueUid, // 🎯 FIX: ใช้ trueUid เป็น Document Key ภายใน Map
        "Image": defaultImageUrl,
        "Address": "" // 💡 เพิ่ม Address ว่าง
      };
      
      // 4. บันทึกเข้า Firestore ด้วย UID จริง (เป็น Document ID)
      await DatabaseMethod().addUserDetails(userInfoMap, trueUid); // 🎯 FIX: ใช้ trueUid

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Registered Successfully",style: TextStyle(fontSize: 20.0),)));

      Navigator.push(context, MaterialPageRoute(builder: (context)=> const BottomNav()));
      
    } on FirebaseException catch(e){
      // ... (Error Handling เดิม)
      if(e.code=='weak'){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Password Provided is too Weak",style: TextStyle(fontSize: 20.0),)));
      }
      else if(e.code=="email-already-in-use"){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Account Already exists",style: TextStyle(fontSize: 20.0),)));
      }
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
                      "SIGN UP",
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9458ED),
                      ),
                    ),
                    
  
                    Text(
                      "please enter details below to continue.",
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 90, 80, 105),
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
                      child: TextFormField(
                        validator: (value){
                          if(value==null|| value.isEmpty){
                            return'Please enter your Name';
                          }
                          return null;
                        },
                        controller: namecontroller,
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
                          hintText: "youremail@email.com",
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
                          // ต้องมีความยาว 8 ตัวเป็นอย่างน้อย
                            if (value.length < 8) {
                                return 'Password must be at least 8 characters long.';
                            }
                            
                            // ต้องมีตัวอักษรพิมพ์ใหญ่อย่างน้อย 1 ตัว
                            if (!value.contains(RegExp(r'[A-Z]'))) {
                                return 'Password must contain at least one uppercase letter.';
                            }
                            
                            // ต้องมีตัวเลขอย่างน้อย 1 ตัว
                            if (!value.contains(RegExp(r'[0-9]'))) {
                                return 'Password must contain at least one number.';
                            }

                            return null; // ผ่านการตรวจสอบ
                            },
                        
                        controller: passwordcontroller,
                        obscureText: true,
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
          
                    SizedBox(height: 30.0),
                    
                    // Signup Button
                    GestureDetector(
                      onTap: (){
                        if(_formkey.currentState!.validate()){
                          setState(() {
                            name= namecontroller.text;
                            email= mailcontroller.text;
                            password= passwordcontroller.text;
                          });
                        }
                        registration();
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
