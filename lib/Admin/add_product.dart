import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:sealyshop/services/database.dart';

class AddProduct extends StatefulWidget {
  // 💡 1. รับ DocumentSnapshot สำหรับโหมดแก้ไข
  final DocumentSnapshot? productToEdit;
  // 💡 FIX: ลบ const ออก
  const AddProduct({super.key, this.productToEdit});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();
  // 💡 NEW: Controller สำหรับ Stock
  TextEditingController stockcontroller = TextEditingController(); 

  // 💡 NEW: State variables สำหรับโหมดแก้ไข
  String? oldImageUrl;
  String? oldProductId;
  String? pageTitle;
  String? oldCategory;

  @override
  void initState() {
    super.initState();
    _loadEditData();
  }

  // 💡 2. ฟังก์ชันโหลดข้อมูลเก่าเมื่อเข้าสู่โหมดแก้ไข
  void _loadEditData() {
    if (widget.productToEdit != null) {
      // โหมดแก้ไข (EDIT MODE)
      pageTitle = "Edit Product";
      oldProductId = widget.productToEdit!.id;
      
      // โหลดค่าเดิม
     Map<String, dynamic> data = widget.productToEdit!.data() as Map<String, dynamic>;
  
      namecontroller.text = data['Name'] ?? '';
      pricecontroller.text = data['Price'] ?? '';
      detailcontroller.text = data['Detail'] ?? '';
      stockcontroller.text = data['Stock']?.toString() ?? ''; // ดึง Stock
      oldImageUrl = data['Image'] ?? '';
      value = data['Category']; // สมมติว่า category ถูกบันทึกด้วย Field 'Category'
      oldCategory = data['Category'];
    } else {
      // โหมดเพิ่มใหม่ (ADD MODE)
      pageTitle = "Add New Product";
    }
  }

  // 💡 3. ฟังก์ชันดึงรูปภาพ (เดิม)
  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
    setState(() {});
  }
  
  // 💡 4. NEW/MODIFIED: ฟังก์ชันรวมสำหรับ Add และ Update
  Future<void> _handleSave() async {
   if (namecontroller.text.isEmpty || pricecontroller.text.isEmpty || detailcontroller.text.isEmpty || value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    // 1. อัปโหลดรูปภาพใหม่ (ถ้ามีการเลือกรูปใหม่) หรือใช้ URL เดิม
    String downloadUrl = oldImageUrl ?? '';
    if (selectedImage != null) {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("blogImage").child(addId);
      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      downloadUrl = await (await task).ref.getDownloadURL();
    } else if (oldImageUrl == null && widget.productToEdit == null) {
        // โหมดเพิ่มใหม่ และไม่มีรูป
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an image.")),
        );
        return;
    }

    String firstletter = namecontroller.text.substring(0, 1).toUpperCase();

    Map<String, dynamic> productInfo = {
        "Name": namecontroller.text,
        "Image": downloadUrl,
        "SearchKey": firstletter,
        "UpdatedName": namecontroller.text.toUpperCase(),
        "Price": pricecontroller.text,
        "Detail": detailcontroller.text,
        
        // ✅ FIX 1: ต้องเพิ่ม Category ที่เลือก/โหลด เข้าไปใน Map
        "Category": value!, 
        
        // ✅ FIX 2: ต้องเพิ่ม Stock ที่กรอกเข้าไปใน Map
        "Stock": stockcontroller.text, 
    };

  try {
    if (widget.productToEdit != null && oldProductId != null) {
      // ⭐️ โหมดแก้ไข (UPDATE MODE)

      String newCategory = productInfo['Category']!; // Category ใหม่
      
      // 💡 NEW LOGIC: ตรวจสอบว่ามีการเปลี่ยน Category หรือไม่
      if (oldCategory != null && oldCategory != newCategory) {
       // 1.1 ถ้าเปลี่ยน Category ให้ลบสินค้าออกจาก Collection Category เก่าก่อน
       // ต้องมั่นใจว่า DatabaseMethod().deleteProductInCategory() ได้ถูกเพิ่มแล้ว
       try {
        await DatabaseMethod().deleteProductInCategory(oldProductId!, oldCategory!);
        print("Product successfully removed from old category: $oldCategory");
       } catch (e) {
        print("Warning: Failed to delete product from old category '$oldCategory': $e");
       }
      }
      
      // 2. อัปเดตใน Collection หลัก (Products)
      // เราสามารถใช้ DatabaseMethod().addProduct ที่ใช้ .set(merge: true) เพื่อความยืดหยุ่นในการอัปเดต Document ID
      await DatabaseMethod().addProduct(oldProductId!, productInfo);
      
      // 3. บันทึก/อัปเดตใน Collection Category ใหม่ (จะสร้างใหม่ถ้าเปลี่ยน, หรืออัปเดตถ้าไม่เปลี่ยน)
      await DatabaseMethod().addProductInCategory(oldProductId!, newCategory, productInfo); 
      
      _showSnackbar("Product updated successfully!");

    } else {
            // ⭐️ โหมดเพิ่มใหม่ (ADD MODE)
            
            // 1. สร้าง ID สำหรับ Document ใหม่
            String productId = randomAlphaNumeric(10); 
            
            // 2. บันทึกใน Collection หลัก (Products)
            await DatabaseMethod().addProduct(productId, productInfo); 
            
            // 3. บันทึกใน Collection Category (Category/ID)
            await DatabaseMethod().addProductInCategory(productId, productInfo['Category']!, productInfo); 
            
            _showSnackbar("Product added successfully!");
        }
        
        // ⭐️ FIX: Navigator.pop(context) ถูกเรียกใช้เมื่อ Transaction สำเร็จ
        // เราจะเรียกมันหลังจากแสดง Snackbar และออกจาก try block
        
    } catch (e) {
        // 💡 FIX: ถ้าการบันทึก/อัปโหลดล้มเหลว (เช่น Network error)
        _showSnackbar("Failed to save product: $e");
        return; // ออกจากฟังก์ชันถ้ามีข้อผิดพลาดหลัก (เช่น อัปโหลดรูปไม่สำเร็จ)
    }
    
    // ⭐️ FIX: เมื่อทุกอย่างเสร็จสมบูรณ์ ให้ทำการ pop กลับไป
    if (mounted) {
        Navigator.pop(context); 
    }
}

  void _showSnackbar(String message) {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF9458ED),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Text(message, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
        ),
      );
  }
  
  void _clearFields() {
    selectedImage = null;
    namecontroller.clear();
    pricecontroller.clear();
    detailcontroller.clear();
    stockcontroller.clear();
    value = null;
    oldImageUrl = null;
  }

  // 💡 (โค้ด uploadItem เดิมถูกรวมเข้ากับ _handleSave แล้ว)
  // ...

  String? value;
  final List<String> categoryitem = [
    'Pen',
    'Pencil',
    'Book',
    'Watercolor',
    'Paper',
    'Eraser'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF9458ED),
              size: 20,
            ),
          ),
        ),
        title: Text(
          pageTitle ?? "Manage Product", // 💡 ใช้ pageTitle
          style: const TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Image Section
              Center(
                child: Column(
                  children: [
                    // ... (Labels for Image)
                    const Text("Product Image", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                    const SizedBox(height: 8),
                    Text("Upload a clear photo of your product", style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
                    const SizedBox(height: 20.0),
                    
                    // Image Picker (MODIFIED)
                    GestureDetector(
                      onTap: getImage,
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFF9458ED).withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9458ED).withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          // 💡 แสดงรูปภาพเดิมเมื่ออยู่ในโหมดแก้ไขและไม่มีรูปใหม่
                          image: (selectedImage == null && oldImageUrl != null)
                              ? DecorationImage(
                                  image: NetworkImage(oldImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.file(selectedImage!, fit: BoxFit.cover),
                              )
                            : (oldImageUrl == null || oldImageUrl!.isEmpty)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFFFF80D3).withOpacity(0.2),
                                              const Color(0xFF9458ED).withOpacity(0.2),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 50,
                                          color: Color(0xFF9458ED),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      const Text("Tap to upload", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: Color(0xFF9458ED))),
                                    ],
                                  )
                                : const SizedBox(), // แสดงรูปเดิมแทนปุ่ม upload
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40.0),

              // 💡 NEW: Product Stock (เพิ่มเข้ามาก่อน Name)
              


              // Product Name (เดิม)
              _buildLabel("Product Name"),
              const SizedBox(height: 12.0),
              _buildTextField(
                controller: namecontroller,
                hint: "Enter product name",
                icon: Icons.inventory_2_outlined,
              ),

              const SizedBox(height: 25.0),

              // Product Price (เดิม)
              _buildLabel("Product Price"),
              const SizedBox(height: 12.0),
              _buildTextField(
                controller: pricecontroller,
                hint: "Enter price (e.g., 120)",
                icon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 25.0),
              _buildLabel("Stock Quantity"),
              const SizedBox(height: 12.0),
              _buildTextField(
                  controller: stockcontroller,
                  hint: "Enter stock quantity",
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number),
              

              const SizedBox(height: 25.0),

              // Product Category (เดิม)
              _buildLabel("Product Category"),
              const SizedBox(height: 12.0),
              Container(
                // ... (Dropdown UI code - ใช้ value และ categoryitem เดิม)
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: categoryitem
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Row(
                              children: [
                                Icon(_getCategoryIcon(item), color: const Color(0xFF9458ED), size: 20),
                                const SizedBox(width: 12),
                                Text(item, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Color(0xFF2D2D2D))),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: ((newValue) => setState(() {
                          value = newValue;
                        })),
                    dropdownColor: Colors.white,
                    hint: Row(
                      children: [
                        Icon(Icons.category_outlined, color: Colors.grey[400], size: 20),
                        const SizedBox(width: 12),
                        Text("Select Category", style: TextStyle(color: Colors.grey[400], fontSize: 15.0)),
                      ],
                    ),
                    iconSize: 28,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9458ED)),
                    value: value,
                  ),
                ),
              ),

              const SizedBox(height: 25.0),

              // Product Detail (เดิม)
              _buildLabel("Product Detail"),
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  maxLines: 5,
                  controller: detailcontroller,
                  style: const TextStyle(fontSize: 15.0, color: Color(0xFF2D2D2D)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Describe your product in detail...",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15.0),
                  ),
                ),
              ),

              const SizedBox(height: 40.0),

              // Add/Update Product Button (MODIFIED)
              GestureDetector(
                onTap: _handleSave, // 💡 ใช้ฟังก์ชันรวม
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF80D3), Color(0xFF9458ED)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9458ED).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.productToEdit != null ? "UPDATE PRODUCT" : "ADD PRODUCT", // 💡 เปลี่ยนข้อความตามโหมด
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  // 💡 Helper Functions (ย้ายเข้ามาใน State Class)
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pen':
        return Icons.edit_outlined;
      case 'Pencil':
        return Icons.create_outlined;
      case 'Book':
        return Icons.menu_book_outlined;
      case 'Watercolor':
        return Icons.palette_outlined;
      case 'Paper':
        return Icons.description_outlined;
      case 'Eraser':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D2D2D),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15.0, color: Color(0xFF2D2D2D)),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15.0),
          prefixIcon: Icon(icon, color: const Color(0xFF9458ED), size: 22),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    namecontroller.dispose();
    pricecontroller.dispose();
    detailcontroller.dispose();
    stockcontroller.dispose(); // 💡 NEW: Dispose stock controller
    super.dispose();
  }
}