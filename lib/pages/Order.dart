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

  getthesharedpref() async {
    email = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  Stream? orderStream;

  getontheload() async {
    await getthesharedpref();
    orderStream = await DatabaseMethod().getOrders(email!);
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  Widget allOrders() {
    return StreamBuilder(
      stream: orderStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];

                  return Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 20.0,
                          top: 10.0,
                          bottom: 10.0,
                        ),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Image.network(
                              ds["ProductImage"],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ds["Product"],
                                    style: AppWidget.semiboldTextFeildStyle(),
                                  ),
                                  Text(
                                    "\$" + ds["Price"],
                                    style: TextStyle(
                                      color: Color(0xFFfd6f36),
                                      fontSize: 23.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Status : " + ds["Status"],
                                    style: TextStyle(
                                      color: Color(0xFFfd6f36),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3E5FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFF3E5FF),
        title: Text("Current Orders", style: AppWidget.boldTextFeildStyle()),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(children: [Expanded(child: allOrders())]),
      ),
    );
  }
}
