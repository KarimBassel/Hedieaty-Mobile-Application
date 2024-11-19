import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/EventList.dart';
import 'package:hedieatymobileapplication/MyPledgedGifts.dart';
import 'package:hedieatymobileapplication/SignUp.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'GiftDetails.dart';
import 'Home.dart';
import 'Profile.dart';
import 'GiftList.dart';
import 'FriendCard.dart';
import 'Base Classes/Gift.dart';
import 'Base Classes/Event.dart';
void main() {
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
      home: Signup(),
    );
  }
}













