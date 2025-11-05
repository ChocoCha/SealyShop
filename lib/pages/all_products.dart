import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/pages/product_detail.dart';
import 'package:sealyshop/services/database.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({super.key});

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  Stream<QuerySnapshot>? productStream;
  String searchQuery = "";
  String selectedCategory = "All";
  String sortBy = "name"; // name, price-low, price-high

  // Categories list
  final List<Map<String, dynamic>> categories = [
    {"name": "All", "icon": Icons.apps},
    {"name": "Pen", "icon": Icons.edit_outlined},
    {"name": "Pencil", "icon": Icons.create_outlined},
    {"name": "Book", "icon": Icons.menu_book_outlined},
    {"name": "Watercolor", "icon": Icons.palette_outlined},
    {"name": "Paper", "icon": Icons.description_outlined},
    {"name": "Eraser", "icon": Icons.cleaning_services_outlined},
  ];

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  getontheload() async {
    productStream = await DatabaseMethod().getAllProducts();
    setState(() {});
  }

  // Filter and Sort products
  List<DocumentSnapshot> filterAndSortProducts(List<DocumentSnapshot> docs) {
    // Filter by search query
    List<DocumentSnapshot> filtered = docs.where((doc) {
      String name = (doc["Name"] ?? "").toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    // Filter by category
    if (selectedCategory != "All") {
      filtered = filtered.where((doc) {
        String category = (doc["Category"] ?? "").toString();
        return category.toLowerCase() == selectedCategory.toLowerCase();
      }).toList();
    }

    // Sort products
    filtered.sort((a, b) {
      if (sortBy == "name") {
        return (a["Name"] ?? "").toString().compareTo((b["Name"] ?? "").toString());
      } else if (sortBy == "price-low") {
        double priceA = double.tryParse(a["Price"]?.toString() ?? "0") ?? 0;
        double priceB = double.tryParse(b["Price"]?.toString() ?? "0") ?? 0;
        return priceA.compareTo(priceB);
      } else if (sortBy == "price-high") {
        double priceA = double.tryParse(a["Price"]?.toString() ?? "0") ?? 0;
        double priceB = double.tryParse(b["Price"]?.toString() ?? "0") ?? 0;
        return priceB.compareTo(priceA);
      }
      return 0;
    });

    return filtered;
  }

  Widget buildAllProductsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: productStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF80D3).withOpacity(0.3),
                        Color(0xFF9458ED).withOpacity(0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9458ED)),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Loading products...",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red.withOpacity(0.5)),
                SizedBox(height: 20),
                Text(
                  "Error loading products",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF80D3).withOpacity(0.2),
                        Color(0xFF9458ED).withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inventory_2_outlined, size: 80, color: Color(0xFF9458ED)),
                ),
                SizedBox(height: 20),
                Text(
                  "No Products Yet",
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        // Filter and sort products
        List<DocumentSnapshot> filteredProducts = filterAndSortProducts(snapshot.data!.docs);

        if (filteredProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                SizedBox(height: 20),
                Text(
                  "No products found",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Try adjusting your filters",
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            mainAxisSpacing: 15.0,
            crossAxisSpacing: 15.0,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = filteredProducts[index];

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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9458ED), Color(0xFFAB7CF5)],
                ),
              ),
              child: Column(
                children: [
                  // Top Bar
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "All Products",
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Browse our collection",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      // Sort Button
                      GestureDetector(
                        onTap: () {
                          _showSortDialog(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.sort, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15.0),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF9458ED), size: 24),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey[400]),
                                onPressed: () {
                                  setState(() {
                                    searchQuery = "";
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Filter Chips
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedCategory == categories[index]["name"];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = categories[index]["name"];
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(colors: [Color(0xFFFF80D3), Color(0xFF9458ED)])
                            : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(0xFF9458ED).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            categories[index]["icon"],
                            size: 18,
                            color: isSelected ? Colors.white : Color(0xFF9458ED),
                          ),
                          SizedBox(width: 8),
                          Text(
                            categories[index]["name"],
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Products Grid
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: buildAllProductsGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.sort, color: Color(0xFF9458ED), size: 24),
                    SizedBox(width: 10),
                    Text(
                      "Sort By",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildSortOption(context, "Name (A-Z)", "name", Icons.sort_by_alpha),
              _buildSortOption(context, "Price (Low to High)", "price-low", Icons.arrow_upward),
              _buildSortOption(context, "Price (High to Low)", "price-high", Icons.arrow_downward),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext context, String title, String value, IconData icon) {
    bool isSelected = sortBy == value;
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [Color(0xFFFF80D3).withOpacity(0.2), Color(0xFF9458ED).withOpacity(0.2)])
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? Color(0xFF9458ED) : Colors.grey[600],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Color(0xFF9458ED) : Color(0xFF2D2D2D),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Color(0xFF9458ED), size: 24)
          : null,
      onTap: () {
        setState(() {
          sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }
}