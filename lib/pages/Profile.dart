import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:sealyshop/pages/onboarding.dart';
import 'package:sealyshop/services/auth.dart';
import 'package:sealyshop/services/shared_pref.dart';
import 'package:sealyshop/widget/support_widget.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? image, name, email;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  getthesharedpref() async {
    image = await SharedPreferenceHelper().getUserImage();
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  @override
  void initState() {
    getthesharedpref();
    super.initState();
  }

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
    uploadItem();
    setState(() {});
  }

  uploadItem() async {
    if (selectedImage != null) {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("blogImage")
          .child(addId);

      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      var dowloadUrl = await (await task).ref.getDownloadURL();
      await SharedPreferenceHelper().saveUserImage(dowloadUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF3E5FF),
        title: Text("Profile", style: AppWidget.boldTextFeildStyle()),
      ),
      backgroundColor: Color(0xFFF3E5FF),
      body: name == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Column(
                children: [
                  selectedImage != null
                      ? GestureDetector(
                        onTap: (){
                          getImage();
                        },
                        child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(60),
                              child: Image.file(
                                selectedImage!,
                                height: 150.0,
                                width: 150.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      )
                      : GestureDetector(
                          onTap: () {
                            getImage();
                          },
                          child: Center(
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(60),
                                child: Image.network(
                                  image!,
                                  height: 150.0,
                                  width: 150.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Material(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 10.0),
                              width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Icon(Icons.person_outlined,size: 35.0,),
                                SizedBox(width: 10.0,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Name",style: AppWidget.lightTextFeildStyle(),),
                                    Text(name!,style: AppWidget.semiboldTextFeildStyle(),)
                                  ],
                                )
                              ],
                            ),),
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Material(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 10.0),
                              width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Icon(Icons.mail_outlined,size: 35.0,),
                                SizedBox(width: 10.0,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Email",style: AppWidget.lightTextFeildStyle(),),
                                    Text(email!,style: AppWidget.semiboldTextFeildStyle(),)
                                  ],
                                )
                              ],
                            ),),
                          ),
                        ),
                        SizedBox(height: 20,),
                        GestureDetector(
                          onTap: () async{
                            await AuthMethod().SignOut().then((value){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Onboarding()));
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 10.0),
                                width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Icon(Icons.logout,size: 35.0,),
                                  SizedBox(width: 10.0,),
                                Text("LogOut",style: AppWidget.semiboldTextFeildStyle(),),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios_outlined)
                                ],
                              ),),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        GestureDetector(
                          onTap: () async{
                            await AuthMethod().deleteuser().then((value){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Onboarding()));
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 10.0),
                                width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,size: 35.0,),
                                  SizedBox(width: 10.0,),
                                Text("Delete Account",style: AppWidget.semiboldTextFeildStyle(),),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios_outlined)
                                ],
                              ),),
                            ),
                          ),
                        )
                ],
              ),
            ),
    );
  }
}
