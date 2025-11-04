import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/pages/product_detail.dart';
import 'package:sealyshop/services/database.dart';

// ⚠️ ต้องมี support_widget เพื่อใช้งาน AppWidget (สมมติว่าคุณมีไฟล์นี้)
// import 'package:sealyshop/widget/support_widget.dart'; 

class CategoryProduct extends StatefulWidget {
  final String category;
  const CategoryProduct({super.key, required this.category});

  @override
  State<CategoryProduct> createState() => _CategoryProductState();
}

class _CategoryProductState extends State<CategoryProduct> {
  Stream? CategoryStream;

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  getontheload() async {
    // 💡 FIX: ดึงสินค้าตาม Category ที่ส่งมา
    CategoryStream = await DatabaseMethod().getProducts(widget.category);
    setState(() {});
  }

  Widget allProducts() {
    return StreamBuilder(
      stream: CategoryStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data.docs.isEmpty) {
          return Center(child: Text("No products found in ${widget.category} category."));
        }
        
        // ⭐️ FIX: ใช้ GridView.builder เพื่อแสดงผลสินค้า
        return GridView.builder(
          padding: EdgeInsets.zero,
          // 💡 กำหนด Layout 2 คอลัมน์ และอัตราส่วนที่เหมาะสม
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65, 
            mainAxisSpacing: 15.0,
            crossAxisSpacing: 15.0,
          ),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];

            // ⭐️ FIX: หุ้ม Tile ด้วย GestureDetector และใช้ Image.network
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetail(
                      detail: ds["Detail"],
                      image: ds["Image"],
                      name: ds["Name"],
                      price: ds["Price"],
                      // ⚠️ Note: ProductDetail ควรรับ Product ID ด้วยถ้าจำเป็น
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Container
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Image.network(
                          ds["Image"],
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 15),

                    // Product Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ds["Name"],
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "\$${ds["Price"]}",
                                style: const TextStyle(
                                  color: Color(0xFF9458ED),
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // 💡 ปุ่ม Add to Cart (Placeholder - ใช้ Logic ใน ProductDetail)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF80D3),
                                      Color(0xFF9458ED),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 20),
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3E5FF),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.category,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Expanded(child: allProducts()),
          ],
        ),
      ),
    );
  }
}