import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sealyshop/Admin/all_orders.dart';

class DatabaseMethod {

  
  // =================================================================
  // 💡 NEW: CART METHODS
  // =================================================================

  Future<DocumentReference<Map<String, dynamic>>> saveOrder(
    Map<String, dynamic> orderInfo,
  ) async {
    return await FirebaseFirestore.instance.collection("Orders").add(orderInfo);
  }

  // หรือใช้ Future<String> เพื่อคืนแค่ Order ID
  Future<String> saveOrderAndReturnId(Map<String, dynamic> orderInfo) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection("Orders")
        .add(orderInfo);
    return ref.id;
  }

  // 💡 NEW: 2. ดึงข้อมูลผู้ใช้ (สำหรับกรอกที่อยู่จัดส่งอัตโนมัติ)
  Future<DocumentSnapshot> getUserDetails(String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get();
  }

  // 💡 NEW: 3. ล้างตะกร้าสินค้าทั้งหมดหลังจากสั่งซื้อสำเร็จ
  Future<void> clearCart(String userId, List<String> docIds) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    CollectionReference cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Cart');

    for (String docId in docIds) {
      batch.delete(cartRef.doc(docId));
    }
    await batch.commit();
  }

  Future<Stream<QuerySnapshot>> getAllProducts() async {
    // ดึงสินค้าจาก Collection 'Products' ทั้งหมด
    return FirebaseFirestore.instance.collection("Products").snapshots();
  }

  Future<void> addProductToCart(
    String userId,
    String productId,
    Map<String, dynamic> productInfoMap,
  ) async {
    // โค้ดภายในให้ใช้ productInfoMap และ productId
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Cart')
        .doc(productId) // 💡 ใช้ productId ที่รับมาเป็น Document ID
        .set(productInfoMap, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getCartProducts(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Cart')
        .snapshots();
  }

  // 3. ลบสินค้าออกจากตะกร้า
  Future<void> removeProductFromCart(String userId, String productId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Cart')
        .doc(productId)
        .delete();
  }

  // =================================================================
  // 💡 NEW: PROFILE METHOD
  // =================================================================

  // 4. อัปเดตข้อมูลผู้ใช้ (สำหรับหน้าแก้ไขโปรไฟล์)
  Future<void> updateUserDetails(
    String userId,
    Map<String, dynamic> newDetails,
  ) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update(
          newDetails,
        ); // newDetails ควรมี field เช่น {'Name': 'ใหม่', 'Address': 'ที่อยู่ใหม่'}
  }

  Future<void> deleteUserDocument(String userId) async {
  // 1. ลบ Document ผู้ใช้ออกจาก Collection 'users'
  return await FirebaseFirestore.instance
      .collection('users')
      .doc(userId) // ใช้ User ID ที่ได้จาก Firebase Auth
      .delete();
}

  // =================================================================
  // ✅ EXISTING METHODS (จากโค้ดเดิมของคุณ)
  // =================================================================

  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  Future addAllProducts(Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("Products")
        .add(userInfoMap);
  }

  UpdateStatus(String id) async {
    return await FirebaseFirestore.instance.collection("Orders").doc(id).update(
      {"Status": "Delivered"},
    );
  }

  Future<Stream<QuerySnapshot>> getProducts(String category) async {
    return FirebaseFirestore.instance.collection(category).snapshots();
  }

  Future<Stream<QuerySnapshot>> AllOrders() async {
    return FirebaseFirestore.instance
        .collection("Orders")
        .where("Status", isEqualTo: "On the way")
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getOrders(String email) async {
    return FirebaseFirestore.instance
        .collection("Orders")
        .where("Email", isEqualTo: email)
        .snapshots();
  }

  Future orderDetails(Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .add(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getDeliveredOrders(String email) async {
    return FirebaseFirestore.instance
        .collection("Orders")
        .where("Email", isEqualTo: email)
        .where("Status", isEqualTo: "Delivered") // ⭐️ กรองสถานะ Delivered
        .snapshots();
}

  Future<QuerySnapshot> search(String updatedname) async {
    return await FirebaseFirestore.instance
        .collection("Products")
        .where(
          "SearchKey",
          isEqualTo: updatedname.substring(0, 1).toUpperCase(),
        )
        .get();
  }

  //adminอะตรงนี้

  // productId คือ Document ID ของสินค้าใน Collection "Products"
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> newInfo,
  ) async {
    return await FirebaseFirestore.instance
        .collection("Products")
        .doc(productId)
        .update(newInfo);
  }

  // 💡 NEW: 2. ลบสินค้า
  Future<void> deleteProduct(String productId, String categoryName) async {
  WriteBatch batch = FirebaseFirestore.instance.batch();

  // 1. ลบจาก Collection หลัก (Products)
  batch.delete(FirebaseFirestore.instance.collection("Products").doc(productId));

  // 2. ลบจาก Collection Category ที่เกี่ยวข้อง
  batch.delete(FirebaseFirestore.instance.collection(categoryName).doc(productId));

  // 3. Commit ทั้งสองการทำงานพร้อมกัน (Atomic Delete)
  await batch.commit();
}

// 💡 NEW: ฟังก์ชันลบสินค้าจาก Collection Category เดี่ยว
Future<void> deleteProductInCategory(String productId, String categoryName) async {
    return await FirebaseFirestore.instance
        .collection(categoryName)
        .doc(productId)
        .delete();
}

  // ✅ NEW/MODIFIED: 1. บันทึก/อัปเดตสินค้าใน Collection หลัก (Products)
Future<void> addProduct(
  String docId, 
  Map<String, dynamic> productInfoMap,
) async {
  // .set(..., merge: true) ทำให้ฟังก์ชันนี้ใช้ได้ทั้ง 'Add' และ 'Update'
  return await FirebaseFirestore.instance
      .collection("Products")
      .doc(docId) 
      .set(productInfoMap, SetOptions(merge: true)); 
}

// 2. บันทึก/อัปเดตสินค้าใน Collection Category
// ใช้สำหรับ Add และ Update
Future<void> addProductInCategory(
  String docId, 
  String categoryname,
  Map<String, dynamic> productInfoMap,
) async {
  return await FirebaseFirestore.instance
      .collection(categoryname)
      .doc(docId) 
      .set(productInfoMap, SetOptions(merge: true)); 
}




// 4. อัปเดตสินค้าใน Collection Category (สำหรับโหมด Update)
Future<void> updateProductInCategory(String productId, String categoryName, Map<String, dynamic> newInfo) async {
    return await FirebaseFirestore.instance
        .collection(categoryName)
        .doc(productId) // ⭐️ ใช้ ID เดียวกัน
        .update(newInfo);
}

// =================================================================
    // 💡 NEW: CHAT METHODS
    // =================================================================

    // 1. สร้าง/รับ Chat Room ID (บังคับเรียงตามตัวอักษร)
    String getChatRoomId(String userId, String adminId) {
      // 💡 เปรียบเทียบเพื่อให้ได้ ID ที่เป็นเอกลักษณ์เสมอ (ID_A_ID_B)
      if (userId.compareTo(adminId) > 0) {
        return "${adminId}_$userId";
      } else {
        return "${userId}_$adminId";
      }
    }

    // 2. ส่งข้อความใหม่ (Future<void> ที่ถูกต้อง)
    Future<void> addMessage(String chatRoomId, Map<String, dynamic> messageInfoMap) async {
      await FirebaseFirestore.instance
          .collection("ChatRooms")
          .doc(chatRoomId)
          .collection("Messages")
          .add(messageInfoMap);
    }

    // 3. ดึงประวัติข้อความใน Chat Room
    Stream<QuerySnapshot> getChatMessages(String chatRoomId) {
      return FirebaseFirestore.instance
          .collection("ChatRooms")
          .doc(chatRoomId)
          .collection("Messages")
          .orderBy("time", descending: true) 
          .snapshots();
    }

    // 4. (Admin) ดึงรายการห้องแชททั้งหมดที่ Admin เกี่ยวข้อง
    Stream<QuerySnapshot> getAllChatRoomsForAdmin(String adminId) {
      return FirebaseFirestore.instance
          .collection("ChatRooms")
          .where("participants", arrayContains: adminId) 
          .snapshots();
    }
}
