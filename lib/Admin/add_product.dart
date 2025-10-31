import 'package:flutter/material.dart';
import 'package:sealyshop/widget/support_widget.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {

String? value;
  final List<String> categoryitem=[
    'Pen','Pencil','Book','Watercolor','Paper','Eraser'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new_outlined)),
        title: Text("Add Product", style:  AppWidget.semiboldTextFeildStyle(),),),
      body: Container(
        margin: EdgeInsets.only(left: 20.0,top: 20.0),
        child: Column(children: [
        Text("Upload the Product Image", style: AppWidget.lightTextFeildStyle()),
        SizedBox(height: 20.0,),
        Center(
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black,width: 1.5), borderRadius: BorderRadius.circular(20)
            ),
            child:  Icon(Icons.camera_alt_outlined),
          
          ),
        ),
        SizedBox(height: 20.0,),
        Text(
          "Procduct Name", 
          style: AppWidget.lightTextFeildStyle()
        ),
        SizedBox(height: 20.0,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color(0xFFececf8),borderRadius: BorderRadius.circular(20)),
          child: TextField(
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
        SizedBox(height: 40.0,),
        Text(
          "Product Category", 
          style: AppWidget.lightTextFeildStyle()
        ),
        SizedBox(height: 20.0,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color:  Color(0xFFececf8),borderRadius:  BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(items: categoryitem
            .map((item)=>DropdownMenuItem(
              value: item, 
              child:  Text(item,
              style: AppWidget.semiboldTextFeildStyle(),)))
            .toList(),
            onChanged:((value)=> setState(() {
              this.value=value;
            })),
            dropdownColor: Colors.white,
            hint: Text("Select Category"),
            iconSize: 36,
            icon: Icon(Icons.arrow_drop_down, color: Colors.black,),
            value: value,
            ),
          ),
          ),
          SizedBox(height: 30.0,),
          Center(child: ElevatedButton(onPressed: (){}, child: Text("Add Product", style: TextStyle(fontSize: 22.0),)))
        

      ],
      ),
      ),
    );
  }
}