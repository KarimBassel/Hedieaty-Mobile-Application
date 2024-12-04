import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Views/Home.dart';
import 'package:hedieatymobileapplication/Views/SignIn.dart';
import '../Models/Friend.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          User? user = authSnapshot.data;
          return FutureBuilder<Friend>(
            future: Friend.getUserObject(int.tryParse(FirebaseAuth.instance.currentUser!.uid.hashCode.toString())!),
            builder: (context, friendSnapshot) {
              if (friendSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (friendSnapshot.hasData) {

                return Home(User: friendSnapshot.data!);
              }


              return SignIn();
            },
          );
        } else {

          return SignIn();
        }
      },
    );
  }
}
