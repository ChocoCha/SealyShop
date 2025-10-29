import 'package:flutter/material.dart';
import 'package:sealyshop/widget/support_widget.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfef5f1) ,
      body: Container(
        padding: EdgeInsets.only(top: 50.0 ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children:[ GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all(),borderRadius: BorderRadius.circular(30)),
                child: Icon(Icons.arrow_back_ios_new_outlined)),
              ),
              Center(child: Image.asset("images/pen2.png",height: 400,))

            ]
          ),

          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 20.0,left: 20.0,right: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20))
              ),
              width: MediaQuery.of(context).size.width,child: 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Fountain Pen", style: AppWidget.boldTextFeildStyle(),),
                      Text("\$150",style: TextStyle(color: Color(0xFFfd6f36),fontSize: 23.0,fontWeight: FontWeight.bold))
                    ],
                  ),
                  SizedBox(height: 20.0,),
                  Text("Details",style: AppWidget.semiboldTextFeildStyle(),),
                  SizedBox(height: 10,),
                  Text("The product is very good fountain pen with smooth ink and line and have refill ink taht you can refill ink inside it "),
                  SizedBox(height: 150,),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    decoration: BoxDecoration(color: Color(0xFFfd6f36),borderRadius: BorderRadius.circular(10)),
                    width: MediaQuery.of(context).size.width,
                    child: Center(child: Text("Buy now", style: TextStyle(color: Colors.white,fontSize: 20.0, fontWeight: FontWeight.bold),)),
                  )
                ],
              ),),
          )
          
      ],),),
    );
  }
}