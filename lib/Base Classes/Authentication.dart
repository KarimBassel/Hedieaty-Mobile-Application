import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'friend.dart';  // Your model.

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  static Future<int?> getUserIdFromRecord(String userId) async {
    final databaseRef = FirebaseDatabase.instance.ref('Users');  // Reference to the 'Users' node

    try {
      // Fetch user data based on the userId
      DatabaseEvent event = await databaseRef.child(userId).once();

      // Check if the data exists for the given userId
      if (event.snapshot.exists) {
        // Get the user data
        var userData = event.snapshot.value as Map<dynamic, dynamic>;

        // Access the 'ID' field inside the user record
        int? userRecordId = userData['ID'];

        return userRecordId;  // Return the user ID if found
      } else {
        print('User with ID $userId not found.');
        return null;  // If user is not found, return null
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      return null;  // Return null in case of an error
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
      ) async {
    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieve the Firebase UID of the newly created user
      String uid = userCredential.user!.uid;

      // Generate the hashcode of the UID to be used as the root of the node
      int userIdHashCode = uid.hashCode;

      // Create a Friend object with the hashcode ID
      Friend newFriend = Friend(
        id: userIdHashCode,
        name: name,
        email: email,
        preferences: preferences,
        PhoneNumber: phoneNumber,
        password: password,
        image: image,
      );

      // Store the additional user data in Firebase Realtime Database
      DatabaseReference userRef = _db.ref().child("Users").child(userIdHashCode.toString());
      await userRef.set(newFriend.toMap());

      return userCredential.user;
    } catch (e) {
      print("Sign-up error: $e");
      return null;
    }
  }


  Future<int?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Sign in the user using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieve the Firebase UID of the signed-in user
      String uid = userCredential.user!.uid;

      // Calculate the hashCode of the UID to use as the root of the node
      int userIdHashCode = uid.hashCode;

      // Reference to the 'Users' node in the database using the hashCode
      DatabaseEvent event = await _databaseReference
          .child('Users')
          .child(userIdHashCode.toString())
          .once();

      if (event.snapshot.exists) {
        // Retrieve the data from the snapshot
        var user = event.snapshot.value as Map<dynamic, dynamic>;

        // Return the user ID (assuming it's an integer)
        return int.tryParse(user['ID'].toString());
      } else {
        print("User data not found in database");
        return null;
      }
    } catch (e) {
      print('Error during sign-in: $e');
      return null;
    }
  }


  // Get the current user
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
