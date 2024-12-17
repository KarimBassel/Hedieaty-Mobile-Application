import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/FirebaseMessaging.dart';
import 'package:hedieatymobileapplication/Views/EventList.dart';
import 'package:hedieatymobileapplication/Views/MyPledgedGifts.dart';
import 'package:hedieatymobileapplication/Views/SignIn.dart';
import 'package:hedieatymobileapplication/Views/SplashScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Authentication.dart';
import 'Views/GiftDetails.dart';
import 'Views/Home.dart';
import 'Views/Profile.dart';
import 'Views/GiftList.dart';
import 'Models/Gift.dart';
import 'Models/Event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Models/Friend.dart';
void main() async{
  //Firebase init
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  

  //on app restart sync the cached data only
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}













