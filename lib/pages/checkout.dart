import 'dart:convert'; // ต้องมีสำหรับ jsonDecode

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' ;
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:sealyshop/services/database.dart';
import 'package:sealyshop/services/shared_pref.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:sealyshop/services/constant.dart';
// 💡 FIX: ต้องมี constant.dart เพื่อเข้าถึง secretkey
// import 'package:sealyshop/services/constant.dart'; 




class CheckoutPage extends StatefulWidget {
  final List<DocumentSnapshot> cartItems;
  final double subtotal;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.subtotal,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // 💡 FIX: เพิ่ม state variables ที่หายไป
  String? userId;
  String? userName; 
  String? userEmail;
  String? userImage;
  Map<String, dynamic>? paymentIntent;

  String deliveryAddress = 'Loading...';
  double totalAmount = 0.0;
  bool isLoading = true;
  String selectedPaymentMethod = 'COD'; // ตัวเลือกเริ่มต้น

  @override
  void initState() {
    super.initState();
    totalAmount = widget.subtotal;
    _loadUserDetails();
  }

  // 💡 1. ดึงข้อมูลผู้ใช้ (สำหรับ Checkout และ OrderInfo)
  Future<void> _loadUserDetails() async {
    userId = await SharedPreferenceHelper().getUserId();
    userName = await SharedPreferenceHelper().getUserName();
    userEmail = await SharedPreferenceHelper().getUserEmail();
    userImage = await SharedPreferenceHelper().getUserImage();

    if (userId != null) {
      DocumentSnapshot userDoc = await DatabaseMethod().getUserDetails(userId!);
      if (userDoc.exists) {
        // ⚠️ FIX: ใช้ตรวจสอบ Field 'Address' อย่างปลอดภัย
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('Address')) {
            deliveryAddress = userData['Address'] ?? 'Please update your address in profile.';
        } else {
            deliveryAddress = 'Please update your address in profile.';
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  // 💡 2. ฟังก์ชันหลักในการสั่งซื้อ (จัดการ COD/Card)
  Future<void> _placeOrder() async {
    if (userId == null || widget.cartItems.isEmpty || totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart is empty or user not logged in.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (selectedPaymentMethod == 'Card') {
      await _startStripePayment(); // เริ่ม Stripe
    } else {
      await _saveOrderToFirebase('COD'); // COD
    }
  }

  // 💡 3. เริ่มกระบวนการ Stripe Payment
  Future<void> _startStripePayment() async {
    // 1. คำนวณราคารวม
    String amountString = (totalAmount * 100).toStringAsFixed(0); 

    // ⭐️ ตรวจสอบราคาก่อนเริ่มกระบวนการ
    if (totalAmount < 1) { // Stripe ต้องมีค่าอย่างน้อย 1 หน่วยสกุลเงิน
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: Payment amount must be at least \$1.00'))
            );
            setState(() { isLoading = false; });
        }
        return;
    }

    try {
      paymentIntent = await createPaymentIntent(amountString, 'USD');
      // ⚠️ ตรวจสอบว่า paymentIntent ถูกสร้างสำเร็จหรือไม่
        if (paymentIntent == null || !paymentIntent!.containsKey('client_secret')) {
             throw Exception("Failed to create Payment Intent or secret key is missing.");
        }
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent?['client_secret'],
              style: ThemeMode.light,
              merchantDisplayName: 'SealyShop',
            ),
          )
          .then((value) {});
      await _displayPaymentSheet();
      
    } catch (e, s) {
        print('Stripe Setup Exception: $e$s');
        if (mounted) {
            // ⭐️ FIX: แสดง Error ที่ชัดเจนขึ้น
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment Setup Failed: Check Stripe Key/Network.')),
            );
            setState(() { isLoading = false; }); // ⭐️ FIX: หยุด Loading
        }
    }
  }

  // 💡 4. แสดง Payment Sheet และบันทึก Order
  Future<void> _displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      
      // ✅ ถ้าชำระสำเร็จ: บันทึก Order
      await _saveOrderToFirebase('Card/Stripe');
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text("Payment Successful!"),
              ],
            ),
          ),
        );
      }
      paymentIntent = null;
    } on StripeException catch (e) {
      print("Stripe Error: $e");
      if (mounted) {
        showDialog(context: context, builder: (_) => const AlertDialog(content: Text("Payment Cancelled or Failed")));
        setState(() { isLoading = false; });
      }
    } catch (e) {
      print('General Payment Error: $e');
      setState(() { isLoading = false; });
    }
  }
  
  // 💡 5. บันทึก Order (ใช้ทั้ง COD และ Card)
  Future<void> _saveOrderToFirebase(String method) async {
    List<Map<String, dynamic>> products = widget.cartItems.map((doc) {
      double price = double.tryParse(doc['Price']?.toString() ?? '0') ?? 0.0;
      int quantity = int.tryParse(doc['Quantity']?.toString() ?? '1') ?? 1;

      return {
        'ProductId': doc.id,
        'Name': doc['Name'],
        'Price': price.toStringAsFixed(2),
        'Quantity': quantity.toString(),
      };
    }).toList();
    
    String orderId = const Uuid().v4(); 
    
    Map<String, dynamic> orderInfo = {
      'OrderId': orderId,
      'UserId': userId,
      'Products': products,
      'TotalAmount': totalAmount.toStringAsFixed(2),
      'DeliveryAddress': deliveryAddress,
      'PaymentMethod': method,
      'Status': 'On the way', 
      'Timestamp': FieldValue.serverTimestamp(),
      
      // 💡 FIX: ใช้ตัวแปรที่ถูกนิยามใน CheckoutPageState
      'Name': userName,
      'Email': userEmail,
      'UserImage': userImage, 
    };

    try {
      await DatabaseMethod().saveOrder(orderInfo);
      
      List<String> docIds = widget.cartItems.map((doc) => doc.id).toList();
      await DatabaseMethod().clearCart(userId!, docIds);
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully! Order ID: $orderId')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      print('Order placement failed: $e');
    } finally {
      if(mounted) {
        setState(() { isLoading = false; });
      }
    }
  }

  // 💡 6. Stripe Utilities (FIX: เข้าถึง jsonDecode)
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      // ⚠️ สมมติว่า constant.dart มี static const secretkey
      // ถ้า constant.dart มีคลาสชื่อ ConstantService ที่มี secretkey อยู่
      // คุณต้องเรียกใช้ให้ถูก
      
      // เราจะสมมติว่าคุณสามารถเข้าถึง secretkey ได้แล้ว:
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          // ⭐️ ใช้ secretkey ที่ถูกนิยามใน constant.dart
          'Authorization': 'Bearer $secretkey', 
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      // ⭐️ ต้องมีการตรวจสอบ response status code
      if (response.statusCode == 200) {
          return jsonDecode(response.body);
      } else {
          // ถ้าสถานะไม่ 200 (เช่น 401 Unauthorized, 400 Bad Request)
          print("Stripe API Error: ${response.statusCode} - ${response.body}");
          throw Exception("Failed to create Payment Intent: Stripe API responded with error.");
      }
    } catch (err) {
      print('err charging user: ${err.toString()}');
      throw Exception('Payment Intent creation failed.');
    }
}

  // 💡 7. คำนวณจำนวนเงิน (FIX: ไม่จำเป็นต้องใช้, โค้ดถูกย้ายไปที่ _startStripePayment แล้ว)
  // แต่ถ้าจำเป็นต้องใช้ ให้แน่ใจว่ามันรับ String และคืน String ที่เป็นเซนต์
  String calculateAmount(String amount) {
    final double baseAmount = double.tryParse(amount) ?? 0.0;
    final calculatedAmount = (baseAmount * 100).toInt(); 
    return calculatedAmount.toString();
  }


  @override
  Widget build(BuildContext context) {
    // ⚠️ FIX: Widget build ต้องใช้ตัวแปรที่รู้จัก
    // ...
    // ... (ส่วน body build)
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: const Color(0xFF9458ED),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. ที่อยู่จัดส่ง
                _buildSectionTitle("Delivery Address"),
                _buildAddressCard(),
                const SizedBox(height: 20),

                // 2. สรุปสินค้า
                _buildSectionTitle("Order Summary (${widget.cartItems.length} items)"),
                ...widget.cartItems.map((item) => _buildItemSummary(item)),
                const SizedBox(height: 20),

                // 3. สรุปราคา
                _buildSectionTitle("Price Details"),
                _buildPriceRow("Subtotal:", "\$${widget.subtotal.toStringAsFixed(2)}"),
                _buildPriceRow("Shipping Fee:", "FREE"), 
                const Divider(),
                _buildPriceRow(
                  "Total Payment:",
                  "\$${totalAmount.toStringAsFixed(2)}",
                  isTotal: true,
                ),
                const SizedBox(height: 30),

                // 💡 NEW: Payment Method Selector
                _buildSectionTitle("Payment Method"),
                Row(
                  children: [
                    Expanded(child: _buildPaymentOption('COD', Icons.money_off, 'Cash on Delivery')),
                    const SizedBox(width: 10),
                    Expanded(child: _buildPaymentOption('Card', Icons.credit_card, 'Credit Card/Stripe')),
                  ],
                ),
                const SizedBox(height: 30),

                // 4. ปุ่มชำระเงิน
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading || totalAmount <= 0 ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF80D3),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      selectedPaymentMethod == 'Card' ? "Pay with Card (\$${totalAmount.toStringAsFixed(2)})" : "Place Order (COD)",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // 💡 NEW: Widget สำหรับตัวเลือกการชำระเงิน
  Widget _buildPaymentOption(String method, IconData icon, String label) {
    bool isSelected = selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0C9FF) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF9458ED) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF9458ED) : Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
          ],
        ),
      ),
    );
  }


  // Helper Widgets (โค้ดเดิมที่ถูกแก้ไขให้ปลอดภัย)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Color(0xFF9458ED)),
        title: const Text("Shipping To:", style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(deliveryAddress),
        trailing: const Icon(Icons.edit, size: 20, color: Color(0xFF9458ED)),
        onTap: () {
          // ➡️ TO DO: นำทางไปหน้า Edit Profile เพื่อแก้ไขที่อยู่
        },
      ),
    );
  }

  Widget _buildItemSummary(DocumentSnapshot item) {
    double price = double.tryParse(item['Price']?.toString() ?? '0') ?? 0.0;
    int quantity = int.tryParse(item['Quantity']?.toString() ?? '1') ?? 1;
    double itemTotal = price * quantity; 
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "${item['Name']} x$quantity", 
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "\$${itemTotal.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF9458ED) : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 22 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFFFF80D3) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}