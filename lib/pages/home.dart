// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/common/widgets/images/image_string.dart';
import 'package:sealyshop/pages/category_products.dart';
import 'package:sealyshop/pages/chat_screen.dart';
import 'package:sealyshop/pages/product_detail.dart';
import 'package:sealyshop/pages/vertical_product_grid.dart';
import 'package:sealyshop/services/database.dart';
import 'package:sealyshop/services/shared_pref.dart';
import 'package:sealyshop/widget/promo_slider.dart';
import 'package:sealyshop/widget/support_widget.dart';
import 'package:sealyshop/widget/theme/textsize.dart';
import 'package:sealyshop/pages/cart.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  List categories = [
    "images/pen.png",
    "images/pencil.png",
    "images/book.png",
    "images/watercolor.png",
    "images/paper.png",
    "images/eraser.png",
  ];

  List Categoryname = [
    "Pen",
    "Pencil",
    "Book",
    "Watercolor",
    "Paper",
    "Eraser",
  ];

  var queryResultSet = [];
  var tempSearchStore = [];
  TextEditingController searchcontroller = TextEditingController();

  initiateSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
        search = false;
      });
      return;
    }

    search = true;
    String searchValue = value.toLowerCase(); // แปลง input เป็น lowercase

    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethod().search(value).then((QuerySnapshot docs) {
        if (!mounted) return;
        queryResultSet = docs.docs.map((e) => e.data()).toList();

        tempSearchStore = queryResultSet
            .where(
              (element) => element['UpdatedName']
                  .toString()
                  .toLowerCase()
                  .startsWith(searchValue),
            )
            .toList();

        setState(() {});
      });
    } else {
      tempSearchStore = queryResultSet
          .where(
            (element) => element['UpdatedName']
                .toString()
                .toLowerCase()
                .startsWith(searchValue),
          )
          .toList();

      setState(() {});
    }
  }

  String? name, image;

  getthesharedpref() async {
    name = await SharedPreferenceHelper().getUserName();
    image = await SharedPreferenceHelper().getUserImage();
    setState(() {});
  }

  String? userId;
  Stream<QuerySnapshot>? cartCountStream;
  Stream<QuerySnapshot>? productStream;

  ontheload() async {
    await getthesharedpref();
    userId = await SharedPreferenceHelper().getUserId();
    if (userId != null) {
      cartCountStream = DatabaseMethod().getCartProducts(userId!);
    }
    productStream = await DatabaseMethod().getAllProducts();
    setState(() {});
    setState(() {});
  }

  void _navigateToChat() {
    String adminId = "4gfJcstTIQlHRzewP0qp"; // ⚠️ แทนที่ด้วย UID Admin จริง
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to start a chat.')),
      );
      return;
    }

    String chatRoomId = DatabaseMethod().getChatRoomId(userId, adminId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatRoomId: chatRoomId,
          otherUserName: "Store Admin",
          otherUserId: adminId,
        ),
      ),
    );
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  int selectedCategoryIndex = -1; // -1 means "All" is selected

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Logic for dismissing keyboard or focusing out
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 241, 241, 241),
        // Use a custom scroll view or check for null name before using ListView
        body: name == null
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                // 💡 CHANGE 1: Use ListView here instead of Column
                child: ListView(
                  // Prevents scrolling if content fits (optional, but good practice)
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero, // Remove default padding
                  children: [
                    // Header Section with GIF Background (Full Width)
                    Stack(
                      children: [
                        // GIF Background Container (เต็มจอ ไม่มีขอบ)
                        SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: Image.asset(
                            "images/bg1.gif",
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Curved Bottom Overlay (สร้างโค้งด้านล่าง)
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF9458ED).withOpacity(0.6),
                                Color(0xFFAB7CF5).withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),

                        // White Curved Bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(0xFFF3E5FF),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                          ),
                        ),

                        // Content Layer
                        Container(
                          height: 220,
                          padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 30.0),
                          child: Column(
                            children: [
                              // Profile Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Hi,${name!}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35.0,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Have a good day!",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      // ⭐️ 1. Chat Icon Button
                                      _buildHeaderIcon(
                                        icon: Icons.chat_bubble_outline,
                                        onTap: _navigateToChat,
                                        isProfile: false,
                                      ),

                                      // ⭐️ 2. Cart Icon (พร้อม Badge - โค้ดเดิมที่แก้ไข)
                                      StreamBuilder<QuerySnapshot>(
                                        stream: cartCountStream,
                                        builder: (context, snapshot) {
                                          int cartCount = snapshot.hasData
                                              ? snapshot.data!.docs.length
                                              : 0;
                                          return _buildCartIcon(cartCount);
                                        },
                                      ),
                                    ],
                                  ),

                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(35),
                                      child: Image.network(
                                        image!,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 25.0),

                              // Search Bar
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: searchcontroller,
                                  onChanged: (value) {
                                    initiateSearch(value);
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Search stationery...",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 15.0,
                                    ),
                                    prefixIcon: search
                                        ? GestureDetector(
                                            onTap: () {
                                              search = false;
                                              tempSearchStore = [];
                                              queryResultSet = [];
                                              searchcontroller.text = "";
                                              setState(() {});
                                            },
                                            child: Icon(Icons.close),
                                          )
                                        : Icon(
                                            Icons.search,
                                            color: Color(0xFF9458ED),
                                            size: 24,
                                          ),
                                    suffixIcon: Container(
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFF80D3),
                                            Color(0xFF9458ED),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.tune,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                      vertical: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    search
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...tempSearchStore.map(
                                  (element) => buildResultCard(element),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ), // Increased padding for consistency
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align to start for better layout
                              children: [
                                //promo banner slider
                                const TPromoSlider(
                                  banners: [
                                    TImages.promoBanner1,
                                    TImages.promoBanner2,
                                    TImages.promoBanner3,
                                  ],
                                ),
                                const SizedBox(height: TSizes.spaceBtwSections),
                              ],
                            ),
                          ),

                    // Categories Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Categories",
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "See all",
                                  style: TextStyle(
                                    color: Color(0xFF9458ED),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15.0),

                        // Categories List (Horizontal ListView is fine)
                        SizedBox(
                          height: 100,
                          child: ListView(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            scrollDirection: Axis.horizontal,
                            children: [
                              // All Category
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategoryIndex = -1;
                                  });
                                },
                                child: Container(
                                  width: 90,
                                  margin: EdgeInsets.only(right: 15.0),
                                  decoration: BoxDecoration(
                                    gradient: selectedCategoryIndex == -1
                                        ? LinearGradient(
                                            colors: [
                                              Color(0xFFFF80D3),
                                              Color(0xFF9458ED),
                                            ],
                                          )
                                        : null,
                                    color: selectedCategoryIndex == -1
                                        ? null
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: selectedCategoryIndex == -1
                                            ? Color(0xFF9458ED).withOpacity(0.3)
                                            : Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.apps,
                                        color: selectedCategoryIndex == -1
                                            ? Colors.white
                                            : Color(0xFF9458ED),
                                        size: 32,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "All",
                                        style: TextStyle(
                                          color: selectedCategoryIndex == -1
                                              ? Colors.white
                                              : Color(0xFF2D2D2D),
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Category Items
                              ...List.generate(
                                categories.length,
                                (index) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCategoryIndex = index;
                                    });
                                  },
                                  child: CategoryTile(
                                    image: categories[index],
                                    isSelected: selectedCategoryIndex == index,
                                    name: Categoryname[index],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30.0),

                    // All Products Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            "Popular Items",

                            style: TextStyle(
                              fontSize: 22.0,

                              fontWeight: FontWeight.bold,

                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 10,),
                    
                    // Products List - 💡 ใช้ StreamBuilder ดึงสินค้าจริงจาก Firebase
                    SizedBox(
                      height: 250,
                      child: StreamBuilder(
                        stream:
                            productStream, // 💡 ใช้ Stream ที่เตรียมไว้ใน ontheload()
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    "Error loading products: ${snapshot.error}",
                                  ),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text("No popular items found."),
                                );
                              }
                              
                              // แสดงผลสินค้าด้วย ListView.builder แนวนอน
                              return ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot ds =
                                      snapshot.data!.docs[index];
                                  // ใช้ buildProductCard ที่รับ DocumentSnapshot
                                  return buildProductCard(ds);
                                },
                              );
                            },
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // --- All Stationery (Vertical Grid) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                "All Stationery",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            const SizedBox(height: 15.0),
                    // ⭐️ NEW: Vertical Grid View (เรียงลงมา)
                    // 💡 ถ้า productStream เป็น null จะแสดง CircularProgressIndicator ในไฟล์ VerticalProductGrid.dart
                    productStream == null
                        ? const Center(child: CircularProgressIndicator())
                        : VerticalProductGrid(
                            productStream:
                                productStream, // ใช้ Stream ที่แก้ไขแล้ว
                          ),

                    const SizedBox(height: 30.0),
                  ],
                ),
              ),
      ),
    );
  }

  // 💡 New helper method to simplify the horizontal product list
  Widget buildProductCard(DocumentSnapshot data) {
    String imagePath = data["Image"];
    String name = data["Name"];
    String price = data["Price"];
    String detail =
        data["Detail"] ?? ""; // ต้องแน่ใจว่า field นี้มีใน Firestore

    // ✅ ใช้ GestureDetector หุ้ม Container ทั้งหมด
    return GestureDetector(
      onTap: () {
        // 💡 เชื่อมโยงไปยัง ProductDetail เหมือนกับที่คุณทำใน CategoryProduct
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(
              detail: detail,
              image: imagePath,
              name: name,
              price: price,
            ),
          ),
        );
      },

      // Container ทั้งหมดที่แสดงผลสินค้า
      child: Container(
        width: 180,
        margin: EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
          // ... (Decoration code)
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Center(
                // ⚠️ ต้องใช้ Image.network สำหรับรูปจาก Firebase URL
                child: Image.network(
                  imagePath,
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Product Info
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    // ... (Style code)
                  ),
                  SizedBox(
                    height: 8.0,
                  ), // เปลี่ยนจาก 50.0 เป็น 8.0 เพื่อให้สวยงามขึ้น
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$$price",
                        // ... (Style code)
                      ),
                      // ปุ่ม Add to Cart (สามารถเพิ่ม onTap ที่นี่เพื่อ Add to Cart โดยตรงได้)
                      Container(
                        padding: EdgeInsets.all(8),
                        // ... (Decoration code)
                        child: Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(
              detail: data["Detail"],
              image: data["Image"],
              name: data["Name"],
              price: data["Price"],
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 20.0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Colors.white),
        height: 100,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(10),
              child: Image.network(
                data["Image"],
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 20.0),
            Text(data["Name"], style: AppWidget.semiboldTextFeildStyle()),
          ],
        ),
      ),
    );
  }
}

// Category Tile Widget
class CategoryTile extends StatelessWidget {
  final String image, name;
  final bool isSelected;

  const CategoryTile({
    super.key,
    required this.image,
    this.isSelected = false,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProduct(category: name),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [Color(0xFFFF80D3), Color(0xFF9458ED)])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Color(0xFF9458ED).withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.asset(
                image,
                height: 35,
                width: 35,
                fit: BoxFit.contain,
                color: isSelected ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildHeaderIcon({
  required IconData icon,
  required VoidCallback onTap,
  required bool isProfile,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(right: isProfile ? 0 : 15),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    ),
  );
}

// 💡 NEW: Helper Widget สำหรับ Cart Icon ที่มี Badge
Widget _buildCartIcon(int cartCount) {
  return GestureDetector(
    onTap: () {
      // ⚠️ FIX: Cart อยู่ใน BottomNav แล้ว ไม่ต้อง push/pop
      // Navigator.push(context, MaterialPageRoute(builder: (context) => Cart()));
    },
    child: Container(
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
            size: 28,
          ),
          if (cartCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF80D3),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$cartCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
