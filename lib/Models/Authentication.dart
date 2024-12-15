import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'friend.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  static Future<int?> getUserIdFromRecord(String userId) async {
    final databaseRef = FirebaseDatabase.instance.ref('Users');

    try {

      DatabaseEvent event = await databaseRef.child(userId).once();

      if (event.snapshot.exists) {

        var userData = event.snapshot.value as Map<dynamic, dynamic>;


        int? userRecordId = userData['ID'];

        return userRecordId;
      } else {
        print('User with ID $userId not found.');
        return null;
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      return null;
    }
  }

// Sign up with email and password
  Future<User?> signUpWithEmailPassword(
      String name,
      String email,
      String preferences,
      String phoneNumber,
      String password,
      String image,
      BuildContext context
      ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;
      int userIdHashCode = uid.hashCode;
      Friend newFriend = Friend(
        id: userIdHashCode,
        name: name,
        email: email,
        preferences: preferences,
        PhoneNumber: phoneNumber,
        password: password,
        image: image,
      );
      DatabaseReference userRef = _db.ref().child("Users").child(userIdHashCode.toString());
      await userRef.set(newFriend.toMap());

      return userCredential.user;
    } catch (e) {
      showCustomSnackBar(context, "$e");
      print("Sign-up error: $e");
      return null;
    }
  }


  Future<int?> signInWithEmailAndPassword(String email, String password,BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;
      int userIdHashCode = uid.hashCode;
      DatabaseEvent event = await _databaseReference
          .child('Users')
          .child(userIdHashCode.toString())
          .once();

      if (event.snapshot.exists) {
        var user = event.snapshot.value as Map<dynamic, dynamic>;
        return int.tryParse(user['ID'].toString());
      } else {
        print("User data not found in database");
        return null;
      }
    } catch (e) {
      showCustomSnackBar(context, "$e");
      print('Error during sign-in: $e');
      return null;
    }
  }



  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void showCustomSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.red}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}


