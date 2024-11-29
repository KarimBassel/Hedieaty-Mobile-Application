import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/EventList.dart';
import 'package:hedieatymobileapplication/MyPledgedGifts.dart';
import 'package:hedieatymobileapplication/SignIn.dart';
import 'package:hedieatymobileapplication/SplashScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Base Classes/Authentication.dart';
import 'GiftDetails.dart';
import 'Home.dart';
import 'Profile.dart';
import 'GiftList.dart';
import 'FriendCard.dart';
import 'Base Classes/Gift.dart';
import 'Base Classes/Event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Base Classes/Database.dart';
import 'Base Classes/Friend.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  Databaseclass dbHelper = Databaseclass();
  dbHelper.setupRealtimeListeners();

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













