import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Controllers/FriendController.dart';
import 'package:hedieatymobileapplication/Database.dart';
import 'package:hedieatymobileapplication/Views/Home.dart';
import 'package:hedieatymobileapplication/Views/SignIn.dart';
import '../Models/Friend.dart';

class SplashScreen extends StatelessWidget {
  final FriendController controller = FriendController();
  final Databaseclass db = Databaseclass();

  @override
  Widget build(BuildContext context) {
    db.initialize(); // Initialize the database before building the UI

    return FutureBuilder<User?>(
      future: Future.value(FirebaseAuth.instance.currentUser),  // Get current authenticated user
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),  // Show loading indicator while waiting for auth
          );
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          // If the user is authenticated, load the Friend object
          User? user = authSnapshot.data;

          return FutureBuilder<Friend>(
            future: Friend.getUserObject(int.tryParse(FirebaseAuth.instance.currentUser!.uid.hashCode.toString())!), // Get Friend object
            builder: (context, friendSnapshot) {
              if (friendSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),  // Show loading indicator while fetching Friend object
                );
              }

              if (friendSnapshot.hasData && friendSnapshot.data != null) {
                // If the Friend object is found, navigate to Home screen
                controller.AlreadyAuthenticatedUser(FirebaseAuth.instance.currentUser!.uid.hashCode);
                return Home(User: friendSnapshot.data!);
              } else {
                // If no Friend object found, navigate to Sign In page
                return SignIn();
              }
            },
          );
        } else {
          // If no user is authenticated, navigate to Sign In page
          return SignIn();
        }
      },
    );
  }
}
