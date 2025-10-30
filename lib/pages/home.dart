// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sealyshop/widget/support_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List categories = [
    "images/pen.png",
    "images/pencil.png",
    "images/book.png",
    "images/watercolor.png",
    "images/paper.png",
    "images/eraser.png",
  ];

  int selectedCategoryIndex = -1; // -1 means "All" is selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with GIF Background (Full Width)
              Stack(
                children: [
                  // GIF Background Container (เต็มจอ ไม่มีขอบ)
                  Container(
                    height: 220,
                    width: double.infinity,
                    child: Image.asset(
                      "images/login4.gif",
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
                      height: 30,
                      decoration: BoxDecoration(
                        color: Color(0xFFF8F9FE),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hey, Shivam 👋",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Good Morning",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
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
                                child: Image.asset(
                                  "images/boy.jpg",
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
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search stationery...",
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15.0,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Color(0xFF9458ED),
                                size: 24,
                              ),
                              suffixIcon: Container(
                                margin: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFFF80D3), Color(0xFF9458ED)],
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
              
              // Categories Section
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
              
              // Categories List
              SizedBox(
                height: 110,
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
                                    Color(0xFF9458ED)
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 25.0),
              
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
              
              // Products List
              SizedBox(
                height: 280,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  scrollDirection: Axis.horizontal,
                  children: [
                    ProductCard(
                      image: "images/pen2.png",
                      name: "Fountain Pen",
                      price: "\$120",
                    ),
                    ProductCard(
                      image: "images/pen10.png",
                      name: "Black Pen",
                      price: "\$65",
                    ),
                    ProductCard(
                      image: "images/pen5.jpg",
                      name: "Faberpastel pen",
                      price: "\$0.5",
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}

// Category Tile Widget
class CategoryTile extends StatelessWidget {
  final String image;
  final bool isSelected;

  CategoryTile({
    super.key,
    required this.image,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: EdgeInsets.only(right: 15.0),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [Color(0xFFFF80D3), Color(0xFF9458ED)],
              )
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
    );
  }
}

// Product Card Widget
class ProductCard extends StatelessWidget {
  final String image;
  final String name;
  final String price;

  ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 15.0),
      decoration: BoxDecoration(
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
            height: 150,
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Center(
              child: Image.asset(
                image,
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
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        color: Color(0xFF9458ED),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF80D3),
                            Color(0xFF9458ED),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF9458ED).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}