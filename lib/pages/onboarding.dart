import 'package:flutter/material.dart';
import 'package:sealyshop/pages/login.dart';

class Onboarding extends StatefulWidget{
  const Onboarding({super.key});

  @override 
  State<Onboarding> createState() => _OnboardingState();}

  class _OnboardingState extends State<Onboarding> {
    @override
    Widget build(BuildContext context){
      return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: EdgeInsets.only(top:50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("images/pen.jpg"),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Explore \nThe Best \nProducts.",//ยินดีต้อนรับสู่ร้านต้นไม้ของเรา
                  style: TextStyle(
                    color: 
                    Colors.black,
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold
                    ),
                ),
              ),
              SizedBox(height: 20.0,),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LogIn()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 20.0),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color:Colors.black,shape: BoxShape.circle),
                      child: Text(
                        "Next",
                        style: TextStyle(
                          color:Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      );

    }

  }