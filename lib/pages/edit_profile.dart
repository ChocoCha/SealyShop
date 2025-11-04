import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/services/database.dart';
import 'package:sealyshop/services/shared_pref.dart';
import 'package:sealyshop/widget/support_widget.dart';
// import 'package:sealyshop/widget/support_widget.dart'; // สำหรับ AppWidget style

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  // 💡 โหลดข้อมูลปัจจุบัน (ชื่อ, ที่อยู่)
  Future<void> _loadCurrentUserData() async {
  userId = await SharedPreferenceHelper().getUserId();
  
  if (userId != null) {
      // ⭐️ FIX 1: ดึงข้อมูลล่าสุดจาก Firestore
      DocumentSnapshot userDoc = await DatabaseMethod().getUserDetails(userId!);
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>? ?? {};

      nameController.text = userData['Name'] ?? await SharedPreferenceHelper().getUserName() ?? '';
      addressController.text = userData['Address'] ?? ''; // 💡 ดึง Address จาก Firebase
      
      // ⭐️ FIX 2: บันทึกข้อมูลล่าสุดที่ดึงจาก Firebase กลับไปใน Shared Pref
      await SharedPreferenceHelper().saveUserName(nameController.text);
      await SharedPreferenceHelper().saveUserAddress(addressController.text); 
  }

  setState(() {
    isLoading = false;
  });
}
  
  // 💡 ฟังก์ชันบันทึกการแก้ไข
  Future<void> _saveChanges() async {
    if (userId == null) return;
    
    // 1. สร้าง Map ข้อมูลที่ต้องการอัปเดต
    Map<String, dynamic> updatedInfo = {
        'Name': nameController.text,
        'Address': addressController.text,
    };
    
    // 2. อัปเดตใน Firebase
    await DatabaseMethod().updateUserDetails(userId!, updatedInfo);
    
    // 3. อัปเดตใน Shared Preferences (เพื่อให้หน้า Profile อัปเดตทันที)
    await SharedPreferenceHelper().saveUserName(nameController.text);
    // ⚠️ ต้องมี SharedPreferenceHelper().saveUserAddress(addressController.text) ด้วย

    // 4. แสดงผลสำเร็จและกลับหน้าหลัก
    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!'))
        );
        Navigator.pop(context); // กลับไปหน้า Profile
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF9458ED),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Edit Name
                Text("Full Name", style: AppWidget.semiboldTextFeildStyle()),
                const SizedBox(height: 8),
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Name"),
                ),
                const SizedBox(height: 20),

                // 2. Edit Address
                Text("Shipping Address", style: AppWidget.semiboldTextFeildStyle()),
                const SizedBox(height: 8),
                TextField(
                    controller: addressController,
                    maxLines: 3,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Address"),
                ),
                const SizedBox(height: 40),

                // 3. Save Button
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF80D3),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
    );
  }
}