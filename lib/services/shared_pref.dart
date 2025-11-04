import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper{

  static String userIdkey= "USERKEY";
  static String userNamekey= "USERNAMEKEY";
  static String userEmailkey= "USEREMAILKEY";
  static String userImagekey= "USERIMAGEKEY";
  static String userAddressKey = "USERADDRESSKEY";

  Future<bool> saveUserId(String getUserId)async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.setString(userIdkey, getUserId);
  }

  Future<bool> saveUserName(String getUserName)async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.setString(userNamekey, getUserName);
  }

  Future<bool> saveUserEmail(String getUserEmail)async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.setString(userEmailkey, getUserEmail);
  }

  Future<bool> saveUserImage(String getUserImage)async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.setString(userImagekey, getUserImage);
  }

  Future<bool> saveUserAddress(String getUserAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userAddressKey, getUserAddress);
  }

  Future<String?> getUserId()async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.getString(userIdkey);
  }

  Future<String?> getUserName()async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.getString(userNamekey);
  }

  Future<String?> getUserEmail()async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.getString(userEmailkey);
  }

  Future<String?> getUserImage()async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.getString(userImagekey);
  }

  Future<String?> getUserAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userAddressKey);
  }

  // ✅ ฟังก์ชันเคลียร์ข้อมูลเวลา Logout
  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(userIdkey);
    await prefs.remove(userNamekey);
    await prefs.remove(userEmailkey);
    await prefs.remove(userImagekey);
    await prefs.remove(userAddressKey);
    // หรือใช้ prefs.clear(); เพื่อเคลียร์ทุก key ในแอป
  }
}
