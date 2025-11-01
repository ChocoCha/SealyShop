import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:sealyshop/services/database.dart';
import 'package:sealyshop/widget/support_widget.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
    setState(() {});
  }

  uploadItem() async {
    if (selectedImage != null && namecontroller.text != "") {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("blogImage").child(addId);

      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      var dowloadUrl = await (await task).ref.getDownloadURL();
    String firstletter= namecontroller.text.substring(0,1).toUpperCase();

      Map<String, dynamic> addProduct = {
        "Name": namecontroller.text,
        "Image": dowloadUrl,
        "SearchKey": firstletter,
        "UpdatedName": namecontroller.text.toUpperCase(),
        "Price": pricecontroller.text,
        "Detail": detailcontroller.text,
      };
      await DatabaseMethod().AddProduct(addProduct, value!).then((value) async {
        await DatabaseMethod().addAllProducts(addProduct);
        selectedImage = null;
        namecontroller.text = "";
        pricecontroller.text = "";
        detailcontroller.text = "";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color(0xFF9458ED),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Product uploaded successfully!",
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }
  }

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
      backgroundColor: Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF9458ED),
              size: 20,
            ),
          ),
        ),
        title: Text(
          "Add Product",
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Image Section
              Center(
                child: Column(
                  children: [
                    Text(
                      "Product Image",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Upload a clear photo of your product",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    
                    // Image Picker
                    selectedImage == null
                        ? GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Color(0xFF9458ED).withOpacity(0.3),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF9458ED).withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF80D3).withOpacity(0.2),
                                          Color(0xFF9458ED).withOpacity(0.2),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 50,
                                      color: Color(0xFF9458ED),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    "Tap to upload",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF9458ED),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: Stack(
                              children: [
                                Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF9458ED).withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.file(
                                      selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF80D3),
                                          Color(0xFF9458ED),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF9458ED).withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),

              SizedBox(height: 40.0),

              // Product Name
              _buildLabel("Product Name"),
              SizedBox(height: 12.0),
              _buildTextField(
                controller: namecontroller,
                hint: "Enter product name",
                icon: Icons.inventory_2_outlined,
              ),

              SizedBox(height: 25.0),

              // Product Price
              _buildLabel("Product Price"),
              SizedBox(height: 12.0),
              _buildTextField(
                controller: pricecontroller,
                hint: "Enter price (e.g., 120)",
                icon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 25.0),

              // Product Category
              _buildLabel("Product Category"),
              SizedBox(height: 12.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
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
                                Icon(
                                  _getCategoryIcon(item),
                                  color: Color(0xFF9458ED),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
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
                        Icon(
                          Icons.category_outlined,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Select Category",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15.0,
                          ),
                        ),
                      ],
                    ),
                    iconSize: 28,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9458ED),
                    ),
                    value: value,
                  ),
                ),
              ),

              SizedBox(height: 25.0),

              // Product Detail
              _buildLabel("Product Detail"),
              SizedBox(height: 12.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  maxLines: 5,
                  controller: detailcontroller,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Color(0xFF2D2D2D),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Describe your product in detail...",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.0),

              // Add Product Button
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
                  borderRadius: BorderRadius.circular(20),
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
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      uploadItem();
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Add Product",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D2D2D),
      ),
    );
  }

  // Helper Widget for Text Fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 15.0,
          color: Color(0xFF2D2D2D),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 15.0,
          ),
          prefixIcon: Icon(
            icon,
            color: Color(0xFF9458ED),
            size: 22,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }

  // Helper Function for Category Icons
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

  @override
  void dispose() {
    namecontroller.dispose();
    pricecontroller.dispose();
    detailcontroller.dispose();
    super.dispose();
  }
}