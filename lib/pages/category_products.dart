import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/pages/product_detail.dart';
import 'package:sealyshop/services/database.dart';

class CategoryProduct extends StatefulWidget {
  String category;
  CategoryProduct({super.key, required this.category});

  @override
  State<CategoryProduct> createState() => _CategoryProductState();
}

class _CategoryProductState extends State<CategoryProduct> {
  Stream? CategoryStream;

  getontheload()async{
    CategoryStream= await DatabaseMethod().getProducts(widget.category);
    setState(() {
      
    });
  }

  @override 
  void initState(){
    getontheload();
    super.initState();
  }

Widget allProducts(){
  return StreamBuilder(stream: CategoryStream, builder: (context,AsyncSnapshot snapshot){
    return snapshot.hasData? GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 0.6, mainAxisSpacing: 10.0),itemCount: snapshot.data.docs.length, itemBuilder: (context, index){
        DocumentSnapshot ds= snapshot.data.docs[index];

        return Container(
                      width: 180,
                      margin: EdgeInsets.only(right: 10.0),
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
                              child: Image.network(
                                ds["Image"],
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
                                  ds["Name"],
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 50.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "\$"+ds["Price"],
                                      style: TextStyle(
                                        color: Color(0xFF9458ED),
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> ProductDetail(detail: ds["Detail"], image: ds["Image"], name: ds["Name"], price: ds["Price"])));
                                      },
                                      child: Container(
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
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
      }):Container();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xFFF3E5FF),
      appBar: AppBar(backgroundColor:Color(0xFFF3E5FF) ,),
      body: Container(
        margin: EdgeInsets.only(left: 20.0,right: 20.0),
        child: Column(
          children: [
            Expanded(child: allProducts())
          ],
        ),
      ),
    );
  }
}