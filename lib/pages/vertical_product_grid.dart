// vertical_product_grid.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/pages/product_detail.dart';

class VerticalProductGrid extends StatelessWidget {
  final Stream<QuerySnapshot>? productStream;

  const VerticalProductGrid({
    super.key,
    required this.productStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: productStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final productDocs = snapshot.data?.docs ?? [];
        
        if (productDocs.isEmpty) {
          return const Center(child: Text("No products available."));
        }

        // 💡 ใช้ GridView.builder เพื่อแสดงผลสินค้าแบบเรียงลงมา
        return GridView.builder(
          // 1. ✅ FIX: บอกให้ GridView ใช้ความสูงเท่าที่เนื้อหาต้องการ
          //    นี่คือสิ่งที่แก้ปัญหาการยืดตัวของช่องว่างและอาการหมุนติ้ว
          shrinkWrap: true, 

          // 2. ✅ FIX: ป้องกันการ Scroll ซ้อนกัน (สำคัญเมื่อ GridView อยู่ใน ListView)
          physics: const NeverScrollableScrollPhysics(), 

          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            childAspectRatio: 0.65, 
            mainAxisSpacing: 15.0,
            crossAxisSpacing: 15.0,
          ),
          itemCount: productDocs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = productDocs[index];
            return ProductItemCard(ds: ds);
          },
        );
      },
    );
  }
}

// 💡 NEW: Widget สำหรับแสดง Product Card เดี่ยวๆ (เพื่อความสะอาด)
class ProductItemCard extends StatelessWidget {
  final DocumentSnapshot ds;
  const ProductItemCard({super.key, required this.ds});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = ds.data() as Map<String, dynamic>;
    String imagePath = data["Image"] ?? "";
    String name = data["Name"] ?? "N/A";
    String price = data["Price"] ?? "0";
    String detail = data["Detail"] ?? "";

    return GestureDetector(
      onTap: () {
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
              height: 120, 
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Image.network(
                  imagePath,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 40, color: Colors.grey);
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
                    name,
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
                        "\$$price",
                        style: const TextStyle(
                          color: Color(0xFF9458ED),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Add to Cart Button (Placeholder)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF80D3), Color(0xFF9458ED)],
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
  }
}