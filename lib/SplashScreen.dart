import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Home.dart';
import 'package:hedieatymobileapplication/SignIn.dart';

import 'Base Classes/Authentication.dart';
import 'Base Classes/Friend.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the user is authenticated when the app starts
    Future.delayed(Duration(seconds: 2), () async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("User signed in: ${user.uid}");
        Friend authenticateduser = await Friend.getUserObject(int.tryParse(user.uid.hashCode.toString())!);
        // User is authenticated, navigate to the home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home(User:authenticateduser)),
        );
      } else {
        // User is not authenticated, navigate to the login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }
    });

    return Scaffold(
      body: Center(child: CircularProgressIndicator()), // A loading indicator while checking authentication
    );
  }
}