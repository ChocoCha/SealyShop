import 'package:flutter/material.dart';
import 'package:sealyshop/widget/support_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
List categories=[
  "images/pen.png",
  "images/pencil.png",
  "images/book.png",
  "images/watercolor.png",
  "images/paper.png",
  "images/eraser.png",
];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: Container(
        margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hey, Shivam",
                      style: AppWidget.boldTextFeildStyle(),
                    ),
                    Text("Good Morning",style: AppWidget.lightTextFeildStyle()
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset("images/boy.jpg",height: 70,width: 70,fit: BoxFit.cover,
                  )
                ),

              ],
            ),
            SizedBox(height: 30.0,),
            Container(
              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
              width: MediaQuery.of(context).size.width,
              child: TextField(
                decoration: InputDecoration(border: InputBorder.none,hintText: "Search Products",hintStyle: AppWidget.lightTextFeildStyle(),prefixIcon:  Icon(Icons.search, color: Colors.black,)),
              ),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Categories",style: AppWidget.semiboldTextFeildStyle(),),
                Text("see all",style: TextStyle(color: Color(0xFFfd6f36),fontSize: 18.0,fontWeight: FontWeight.bold))
              ],
            ),
            SizedBox(height:20.0),
            Row(
              children: [
                Container(
                  height: 130,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFFD6F3E),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(child: Text("All",style: TextStyle(color: Colors.white,fontSize: 20.0,fontWeight: FontWeight.bold),))
                ),
                Expanded(
                  child: Container(
                    height: 130 ,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                    itemCount:categories.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context,index){
                      return CategoryTile(image: categories[index]);
                    }),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("All Products",style: AppWidget.semiboldTextFeildStyle(),),
                Text("see all",style: TextStyle(color: Color(0xFFfd6f36),fontSize: 18.0,fontWeight: FontWeight.bold))
              ],
            ),
            SizedBox(height: 20.0,),
            Container(
              height: 240,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 20.0) ,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Image.asset("images/pen2.png",height: 150,width: 150, fit: BoxFit.cover),
                        Text("Fountain Pen", style: AppWidget.semiboldTextFeildStyle(),),
                        SizedBox(height: 10.0,),
                        Row(
                          children: [
                          Text("\$120" ,style: TextStyle(color: Color(0xFFfd6f36), fontSize: 22.0 ,fontWeight: FontWeight.bold ),),
                          SizedBox(width: 50.0,),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(color: Color(0xFFfd6f36),borderRadius: BorderRadius.circular(7)),
                            child: Icon(Icons.add, color: Colors.white,),
                          )
                        ],)
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20.0) ,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Image.asset("images/pen10.png",height: 150,width: 150, fit: BoxFit.cover),
                        Text("Black Pen", style: AppWidget.semiboldTextFeildStyle(),),
                        SizedBox(height: 10.0,),
                        Row(
                          children: [
                          Text("\$65" ,style: TextStyle(color: Color(0xFFfd6f36), fontSize: 22.0 ,fontWeight: FontWeight.bold ),),
                          SizedBox(width: 50.0,),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(color: Color(0xFFfd6f36),borderRadius: BorderRadius.circular(7)),
                            child: Icon(Icons.add, color: Colors.white,),
                          )
                        ],)
                      ],
                    ),
                  ),
                   Container(
                    margin: EdgeInsets.only(right: 20.0) ,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Image.asset("images/pen5.jpg",height: 150,width: 150, fit: BoxFit.cover),
                        Text("Faberpastel pen", style: AppWidget.semiboldTextFeildStyle(),),
                        SizedBox(height: 10.0,),
                        Row(
                          children: [
                          Text("\$0.5" ,style: TextStyle(color: Color(0xFFfd6f36), fontSize: 22.0 ,fontWeight: FontWeight.bold ),),
                          SizedBox(width: 50.0,),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(color: Color(0xFFfd6f36),borderRadius: BorderRadius.circular(7)),
                            child: Icon(Icons.add, color: Colors.white,),
                          )
                        ],)
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  String image;
  CategoryTile({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(right: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(children: [
      Image.asset(image,height: 50,width: 50,fit: BoxFit.cover,),
      Icon(Icons.arrow_forward),
      ],),
    );
  }
}