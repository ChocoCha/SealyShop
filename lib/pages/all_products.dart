import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/pages/product_detail.dart';
import 'package:sealyshop/services/database.dart';
// ⚠️ อย่าลืม import support_widget.dart ถ้าคุณต้องการใช้ AppWidget

class AllProducts extends StatefulWidget { // 💡 เปลี่ยนชื่อคลาส
  const AllProducts({super.key});

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  Stream<QuerySnapshot>? productStream; // 💡 เปลี่ยนชื่อตัวแปรให้สื่อถึงสินค้าทั้งหมด

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  getontheload() async {
    // ⭐️ FIX: เรียกใช้เมธอด getAllProducts() จาก DatabaseMethod
    // (ซึ่งเมธอดนี้ควรคืนค่า Stream<QuerySnapshot> ของสินค้าทั้งหมดจาก Collection "Products")
    productStream = await DatabaseMethod().getAllProducts();
    setState(() {});
  }

  Widget buildAllProductsGrid() { // 💡 เปลี่ยนชื่อเมธอด
    return StreamBuilder<QuerySnapshot>( // กำหนด Type ให้ชัดเจน
      stream: productStream, // ใช้ Stream ที่ดึงสินค้าทั้งหมด
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
           return Center(child: Text("Error loading products: ${snapshot.error}"));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No products found in the shop."));
        }
        
        // ⭐️ ใช้ GridView.builder เพื่อแสดงผลสินค้า
        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(), // ทำให้ Scroll Smooth ขึ้น
          // 💡 กำหนด Layout 2 คอลัมน์ และอัตราส่วนที่เหมาะสม
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65, 
            mainAxisSpacing: 15.0,
            crossAxisSpacing: 15.0,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];

            // ⭐️ Product Tile Widget (อ้างอิงจากโค้ด CategoryProduct เดิม)
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
                      // เพิ่ม Product ID ถ้าต้องการ: id: ds.id
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
                      height: 100,
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
                              // ปุ่ม Add to Cart
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
        title: const Text( // 💡 เปลี่ยน Title เป็น "All Products"
          "All Products",
          style: TextStyle(
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
            Expanded(child: buildAllProductsGrid()), // 💡 ใช้เมธอดใหม่
          ],
        ),
      ),
    );
  }
}