import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod{

  final FirebaseAuth auth= FirebaseAuth.instance;

  Future SignOut()async{
    await FirebaseAuth.instance.signOut();
  }

  Future deleteuser()async{
    User? user= FirebaseAuth.instance.currentUser;
    user?.delete();
  }
  
}