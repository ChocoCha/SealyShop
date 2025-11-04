import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:sealyshop/pages/edit_profile.dart';
import 'package:sealyshop/pages/onboarding.dart';
import 'package:sealyshop/services/auth.dart';
import 'package:sealyshop/services/shared_pref.dart';
import 'package:sealyshop/services/database.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? image, name, email, address;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool isUploading = false;

  getthesharedpref() async {
    image = await SharedPreferenceHelper().getUserImage();
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();
    address = await SharedPreferenceHelper().getUserAddress();
    setState(() {});
  }

  @override
  void initState() {
    getthesharedpref();
    super.initState();
  }

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {
        isUploading = true;
      });
      await uploadItem();
      setState(() {
        isUploading = false;
      });
    }
  }

  uploadItem() async {
    if (selectedImage != null) {
        String addId = randomAlphaNumeric(10);
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child("blogImage").child(addId);

        final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
        var dowloadUrl = await (await task).ref.getDownloadURL();
        
        // 1. บันทึกใน Shared Prefs (โค้ดเดิม)
        await SharedPreferenceHelper().saveUserImage(dowloadUrl);
        
        // 🌟 FIX: บันทึก URL ใหม่กลับไปที่ Firestore
        String? userId = await SharedPreferenceHelper().getUserId();
        if (userId != null) {
            await DatabaseMethod().updateUserDetails(
                userId, 
                {'Image': dowloadUrl} // ใช้อัปเดตเฉพาะ Field 'Image'
            );
        } else {
            // กรณี Log in ไม่สำเร็จ ให้ใช้ UID จาก Firebase Auth โดยตรง
            String uid = AuthMethod().auth.currentUser!.uid;
            await DatabaseMethod().updateUserDetails(uid, {'Image': dowloadUrl});
        }
        
        setState(() {
            image = dowloadUrl;
        });
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FE),
      body: name == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF80D3).withOpacity(0.3),
                          Color(0xFF9458ED).withOpacity(0.3),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF9458ED)),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Loading profile...",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section with Gradient
                  Stack(
                    children: [
                      Container(
                        height: 280,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF9458ED),
                              Color(0xFFAB7CF5),
                            ],
                          ),
                        ),
                      ),
                      // Decorative Circles
                      Positioned(
                        top: 50,
                        right: 30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 150,
                        left: 20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      
                      // Content
                      SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              
                              SizedBox(height: 20.0,),
                              // Title
                              Text(
                                "My Profile , ${name!}",
                                style: TextStyle(
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Profile Photo
                              _buildProfilePhoto(context),
                              SizedBox(height: 15),
                              SizedBox(height: 5),
                              // Email
                              
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Profile Info Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Account Information",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        SizedBox(height: 15),

                        // Name Card
                        _buildProfileCard(
                          context,
                          label: "Full Name",
                          value: name!,
                          icon: Icons.person_outline,
                          onEdit: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
                            getthesharedpref();
                          },
                        ),

                        SizedBox(height: 15),

                        // Email Card
                        _buildProfileCard(
                          context,
                          label: "Email Address",
                          value: email!,
                          icon: Icons.email_outlined,
                          isEditable: false,
                        ),

                        SizedBox(height: 15),

                        // Address Card
                        _buildProfileCard(
                          context,
                          label: "Shipping Address",
                          value: address ?? "Click to set address",
                          icon: Icons.location_on_outlined,
                          onEdit: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
                            getthesharedpref();
                          },
                        ),

                        SizedBox(height: 30),

                        // Actions Section
                        Text(
                          "Account Actions",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        SizedBox(height: 15),

                        // Logout Button
                        _buildActionButton(
                          context,
                          icon: Icons.logout,
                          label: "Log Out",
                          subtitle: "Sign out from your account",
                          color: Color(0xFF9458ED),
                          onTap: () async {
                            _showLogoutDialog(context);
                          },
                        ),

                        SizedBox(height: 15),

                        // Delete Account Button
                        _buildActionButton(
                          context,
                          icon: Icons.delete_outline,
                          label: "Delete Account",
                          subtitle: "Permanently delete your account",
                          color: Colors.red,
                          onTap: () async {
                            _showDeleteDialog(context);
                          },
                        ),

                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfilePhoto(BuildContext context) {
    String displayImage = selectedImage != null
        ? selectedImage!.path
        : (image ?? 'https://via.placeholder.com/150');

    bool isFile = selectedImage != null;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: Container(
              height: 130.0,
              width: 130.0,
              color: Colors.white,
              child: isFile
                  ? Image.file(
                      File(displayImage),
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      displayImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.person,
                          size: 70,
                          color: Color(0xFF9458ED),
                        ),
                      ),
                    ),
            ),
          ),
        ),
        // Edit Button
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: getImage,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF80D3),
                    Color(0xFF9458ED),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF9458ED).withOpacity(0.4),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: isUploading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onEdit,
    bool isEditable = true,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF80D3).withOpacity(0.2),
                  Color(0xFF9458ED).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24.0,
              color: Color(0xFF9458ED),
            ),
          ),
          SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isEditable)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF9458ED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF9458ED),
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24.0,
                color: color,
              ),
            ),
            SizedBox(width: 15.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Color(0xFF9458ED), size: 28),
              SizedBox(width: 10),
              Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(fontSize: 15.0),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16.0,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9458ED),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await SharedPreferenceHelper().clearUserData();
                await AuthMethod().SignOut().then((_) {
                  
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Onboarding(),
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text(
                "Delete Account",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            "This action cannot be undone. Are you sure you want to permanently delete your account?",
            style: TextStyle(fontSize: 15.0),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16.0,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
        Navigator.of(context).pop();
                
                String? userId = AuthMethod().auth.currentUser?.uid;
                
                try {
                    // 1. ลบข้อมูลผู้ใช้จาก Firestore
                    if (userId != null) {
                        await DatabaseMethod().deleteUserDocument(userId);
                    }
                    
                    // 2. ลบบัญชีผู้ใช้จาก Firebase Authentication
                    await AuthMethod().deleteuser();
                    
                    // 3. ล้าง Shared Preferences
                    await SharedPreferenceHelper().clearUserData(); 
                    
                } catch (e) {
                    // 💡 ถ้าการลบ Auth/Document มีปัญหา (เช่น ต้อง Re-Auth)
                    print("Error during deletion: $e");
                    // เรายังคงล้างข้อมูลและนำทางต่อไป เพื่อป้องกันแอปค้าง
                    await SharedPreferenceHelper().clearUserData();
                }
                
                // ⭐️ FIX: นำทางไปยัง Onboarding หลังจากการดำเนินการทั้งหมดเสร็จสิ้น
        Navigator.pushReplacement(
         context,
         MaterialPageRoute(
          builder: (context) => const Onboarding(),
         ),
        );
       },
            ),
          ],
        );
      },
    );
  }
}