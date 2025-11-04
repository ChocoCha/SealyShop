import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/pages/bottomnav.dart';
import 'package:sealyshop/pages/checkout.dart';
import 'package:sealyshop/services/database.dart';
import 'package:sealyshop/services/shared_pref.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  String? userId;
  Stream<QuerySnapshot>? cartStream;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    getUserIdAndCartData();
  }

  getUserIdAndCartData() async {
    userId = await SharedPreferenceHelper().getUserId();
    if (userId != null) {
      cartStream = DatabaseMethod().getCartProducts(userId!);
      setState(() {});
    }
  }

  void calculateTotalPrice(List<QueryDocumentSnapshot> docs) {
    double tempTotal = 0.0;
    for (var doc in docs) {
      double price = double.tryParse(doc['Price']?.toString() ?? '0') ?? 0.0;
      int quantity = int.tryParse(doc['Quantity']?.toString() ?? '1') ?? 1;

      tempTotal += price * quantity;
    }
    if (mounted) {
      setState(() {
        totalPrice = tempTotal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FE),
      body: userId == null
          ? Center(
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF9458ED)),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Loading cart...",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Custom Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF9458ED),
                        Color(0xFFAB7CF5),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> BottomNav()));
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Shopping Cart",
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "Review your items",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Cart Items
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: cartStream,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF9458ED)),
                                  strokeWidth: 3,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Loading items...",
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
                              Icon(
                                Icons.error_outline,
                                size: 80,
                                color: Colors.red.withOpacity(0.5),
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Error loading cart",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      List<QueryDocumentSnapshot> cartList =
                          snapshot.data?.docs.cast<QueryDocumentSnapshot>() ?? [];

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (snapshot.hasData) {
                          calculateTotalPrice(cartList);
                        }
                      });

                      if (cartList.isEmpty) {
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
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 80,
                                  color: Color(0xFF9458ED),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Your Cart is Empty",
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Add items to get started",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 30),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> BottomNav()));
                                },
                                icon: Icon(Icons.shopping_bag_outlined),
                                label: Text("Start Shopping"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF9458ED),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        itemCount: cartList.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot doc = cartList[index];
                          return CartItemTile(
                            doc: doc,
                            userId: userId!,
                          );
                        },
                      );
                    },
                  ),
                ),

                // Cart Summary
                StreamBuilder<QuerySnapshot>(
                  stream: cartStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return SizedBox.shrink();
                    }
                    List<QueryDocumentSnapshot> cartList =
                        snapshot.data?.docs.cast<QueryDocumentSnapshot>() ?? [];
                    return _buildCartSummary(context, cartList);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildCartSummary(
      BuildContext context, List<QueryDocumentSnapshot> cartItems) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary Details
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xFF9458ED),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Items (${cartItems.length})",
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "\$${totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      Text(
                        "\$${totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9458ED),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            // Checkout Button
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
                  onTap: totalPrice > 0
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(
                                cartItems: cartItems,
                                subtotal: totalPrice,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_checkout,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Proceed to Checkout",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Cart Item Tile Widget ---
class CartItemTile extends StatelessWidget {
  final DocumentSnapshot doc;
  final String userId;
  final DatabaseMethod databaseMethod = DatabaseMethod();

  CartItemTile({super.key, required this.doc, required this.userId});

  Widget _buildQuantityButton(
      BuildContext context,
      IconData icon,
      int change,
      String productId,
      int currentQuantity,
      DocumentSnapshot doc) {
    Map<String, dynamic> currentData = doc.data() as Map<String, dynamic>;

    bool isMinusDisabled = change == -1 && currentQuantity <= 1;

    return GestureDetector(
      onTap: () async {
        int newQuantity = currentQuantity + change;

        if (userId.isEmpty) return;

        if (newQuantity > 0) {
          Map<String, dynamic> updatedData = Map.from(currentData);
          updatedData['Quantity'] = newQuantity.toString();

          await databaseMethod.addProductToCart(userId, productId, updatedData);
        } else if (newQuantity == 0 && change == -1) {
          await databaseMethod.removeProductFromCart(userId, productId);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: !isMinusDisabled
              ? LinearGradient(
                  colors: [
                    Color(0xFFFF80D3).withOpacity(0.2),
                    Color(0xFF9458ED).withOpacity(0.2),
                  ],
                )
              : null,
          color: isMinusDisabled ? Colors.grey[200] : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isMinusDisabled ? Colors.grey[400] : Color(0xFF9458ED),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String productId = doc.id;
    String name = doc['Name'] ?? 'No Name';
    String image = doc['Image'] ?? 'https://via.placeholder.com/150';
    double price = double.tryParse(doc['Price']?.toString() ?? '0') ?? 0.0;
    int quantity = int.tryParse(doc['Quantity']?.toString() ?? '1') ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Color(0xFFF8F9FE),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(width: 15),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Color(0xFF2D2D2D),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Delete Button
                      GestureDetector(
                        onTap: () {
                          databaseMethod.removeProductFromCart(userId, productId);
                        },
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Price
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF80D3).withOpacity(0.2),
                          Color(0xFF9458ED).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "\$${(price * quantity).toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Color(0xFF9458ED),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Quantity Controls
                  Row(
                    children: [
                      _buildQuantityButton(
                        context,
                        Icons.remove,
                        -1,
                        productId,
                        quantity,
                        doc,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        context,
                        Icons.add,
                        1,
                        productId,
                        quantity,
                        doc,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "\$${price.toStringAsFixed(2)} each",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
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