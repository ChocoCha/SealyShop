import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sealyshop/Admin/home_admin.dart';
import 'package:sealyshop/pages/DeliveredOrdersHistory.dart';
import 'package:sealyshop/pages/bottomnav.dart';
import 'package:sealyshop/pages/home.dart';
import 'package:sealyshop/pages/login.dart';
import 'package:sealyshop/pages/onboarding.dart';
import 'package:sealyshop/services/constant.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey=publishablekey;
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // การแปลสำหรับ Material Widgets (เช่น Date Picker)
        GlobalWidgetsLocalizations.delegate, // การแปลสำหรับ Text Direction (LTR/RTL)
        GlobalCupertinoLocalizations.delegate, // สำหรับ iOS
        // ถ้าคุณมีการแปลเอง (Custom Translation) ให้เพิ่ม Delegate ของคุณที่นี่
      ],
      supportedLocales: const [
        Locale('en', ''), // English (อังกฤษ)
        Locale('th', ''), // Thai (ไทย) ⭐️
        // เพิ่มภาษาอื่นๆ ที่คุณต้องการรองรับ
      ],
      title: 'Sealy Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Nunito',
        primarySwatch: Colors.purple,
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Onboarding(),
    );
  }
}