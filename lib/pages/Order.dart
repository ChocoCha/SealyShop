import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/pages/product_detail.dart';
import 'package:sealyshop/services/database.dart';
import 'package:sealyshop/services/shared_pref.dart';
import 'package:sealyshop/widget/support_widget.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? email;
  Stream? orderStream;

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  getthesharedpref() async {
    email = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  getontheload() async {
    await getthesharedpref();
    if (email != null && email!.isNotEmpty) {
      orderStream = await DatabaseMethod().getOrders(email!);
      setState(() {});
    }
  }

  Widget allOrders() {
    return StreamBuilder(
      stream: orderStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
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
                  "Loading your orders...",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.data.docs.isEmpty) {
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
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Color(0xFF9458ED),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "No Orders Yet",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Start shopping to see your orders here",
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: 10, bottom: 20),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];

            List products;
            bool isNewOrder =
                (ds.data() as Map<String, dynamic>).containsKey('Products');

            if (isNewOrder) {
              products = ds['Products'] as List? ?? [];
            } else {
              products = [
                {
                  'Name': ds['Product'] ?? 'Single Item',
                  'Price': ds['Price'] ?? '0.00',
                  'Quantity': '1',
                  'Image': ds['ProductImage'] ??
                      ds['Image'] ??
                      'https://via.placeholder.com/100',
                }
              ];
            }

            String orderStatus = ds["Status"] ?? "Pending";
            String totalAmount = isNewOrder
                ? (ds["TotalAmount"] ?? "0.00")
                : (ds["Price"] ?? "0.00");

            return Container(
              margin: const EdgeInsets.only(bottom: 20.0),
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
                children: [
                  // Header Section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFF80D3).withOpacity(0.1),
                          Color(0xFF9458ED).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Order ID
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFF80D3),
                                        Color(0xFF9458ED),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.receipt_long,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order ID",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "#${ds.id.substring(0, 8).toUpperCase()}",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Status Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(orderStatus)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getStatusColor(orderStatus),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(orderStatus),
                                    size: 16,
                                    color: _getStatusColor(orderStatus),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    orderStatus,
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(orderStatus),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Products Section
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Items (${products.length})",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        SizedBox(height: 15),
                        ...products.map((product) {
                          return _buildOrderItem(product as Map<String, dynamic>);
                        }),
                        
                        SizedBox(height: 20),
                        
                        // Total Section
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFF80D3).withOpacity(0.1),
                                Color(0xFF9458ED).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.payments_outlined,
                                    color: Color(0xFF9458ED),
                                    size: 24,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Total Amount",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "\$$totalAmount",
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9458ED),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> product) {
    String name = product['Name'] ?? 'No Name';
    String price = product['Price'] ?? '0.00';
    String quantity = product['Quantity'] ?? '1';
    String productImage = product['Image'] ??
        'https://via.placeholder.com/100/A020F0/FFFFFF?text=No+Image';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                productImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Color(0xFFF8F9FE),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey[400],
                      size: 30,
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
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 14,
                            color: Color(0xFF9458ED),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "x$quantity",
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9458ED),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Text(
                      "\$$price",
                      style: TextStyle(
                        color: Color(0xFF9458ED),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
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

  // Helper function for status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'processing':
      case 'shipped':
        return Color(0xFF9458ED);
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper function for status icon
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'processing':
        return Icons.autorenew;
      case 'shipped':
        return Icons.local_shipping;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

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
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF80D3).withOpacity(0.2),
                    Color(0xFF9458ED).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFF9458ED),
                size: 22,
              ),
            ),
            SizedBox(width: 12),
            Text(
              "My Orders",
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Expanded(child: allOrders()),
          ],
        ),
      ),
    );
  }
}