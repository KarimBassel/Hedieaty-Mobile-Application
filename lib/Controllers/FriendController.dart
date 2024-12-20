import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:hedieatymobileapplication/FirebaseMessaging.dart';
import 'package:hedieatymobileapplication/Authentication.dart';
import 'package:image_picker/image_picker.dart';
import '../Database.dart';
import '../Models/Friend.dart';
import '../Models/Gift.dart';
import '../NotificationService.dart';
import '../Views/Home.dart';
import '../Views/MyPledgedGifts.dart';
import '../Views/Profile.dart';
import '../Views/EventList.dart';
import '../Views/SignIn.dart';
import '../Views/SignUp.dart';
class FriendController {
  final Databaseclass db = Databaseclass();
  final databaseRef = FirebaseDatabase.instance.ref();
  final AuthService auth = AuthService();

//Home
  ProfileIconTap(int userid, BuildContext context) async {
    Friend? uptodate = await Friend.getUserObject(userid);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            Profile(User: uptodate),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }


  //Home
  CreateEventOnTap(int userid, BuildContext context) async {
    Friend user = await Friend.getUserObject(userid);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EventListPage(isOwner: true, User: user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }


//Home
  FriendCardOnTap(int friendid, Friend user, BuildContext context) async {
    Friend friend = await Friend.getUserObject(friendid);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EventListPage(isOwner: false, User: user, friend: friend),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

//Home
  AddFriendFromContacts(FlutterNativeContactPicker _contactPicker, Friend User, BuildContext context) async {
    Contact? contact = await _contactPicker.selectContact();
    if (contact != null) {
      String ExtractedNumber = contact!.phoneNumbers
          .toString()
          .replaceAll(RegExp(r'[\[\]]'), '')
          .replaceFirst('+2', '');
      //print(ExtractedNumber);
      if (User.PhoneNumber == ExtractedNumber)
        showCustomSnackBar(context, "Cannot Add Yourself");
      else {
        int generatedid = await generateUniqueFriendId();
        dynamic newfriend = await Friend.registerFriend(
            User.id!, ExtractedNumber,generatedid);
        if (newfriend is bool) {
          Friend updatedUser = await Friend.getUserObject(User.id!);
          User = updatedUser!;
          showCustomSnackBar(context, "User Not Found");
          return User.friendlist;
        }
        else {
          Friend updatedUser = await Friend.getUserObject(User.id!);
          User = updatedUser!;
          return User.friendlist;
        }
      }
    }else{
      Friend updatedUser = await Friend.getUserObject(User.id!);
      User = updatedUser!;
      return User.friendlist;
    }
  }
//Home
  AddFriendManual(TextEditingController PhoneController, Friend User, BuildContext context) async {
    try {
      final phone = PhoneController.text;

      // Check if the phone number matches the user's phone number
      if (User.PhoneNumber == phone) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        //showCustomSnackBar(context, "Cannot Add Yourself");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot Add Yourself'),
            duration: Duration(seconds: 5),
          ),
        );
        Friend updatedUser = await Friend.getUserObject(User.id!);
        return updatedUser.friendlist;
      }

      // Check if the friendship already exists
      else if (await Friend.checkFriendshipExists(User.id!, phone)) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Friendship already exists'),
            duration: Duration(seconds: 5),
          ),
        );
        Friend updatedUser = await Friend.getUserObject(User.id!);
        return updatedUser.friendlist;
      }

      // Proceed to add a new friend
      else {
        int generatedid = await generateUniqueFriendId();
        dynamic newfriend = await Friend.registerFriend(User.id!, phone, generatedid);

        // If the user was not found
        if (newfriend is bool) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User not found'),
              duration: Duration(seconds: 5),
            ),
          );
          Friend updatedUser = await Friend.getUserObject(User.id!);
          return updatedUser.friendlist;
        } else {
          // Sync friends table to Firebase and set up listeners
          await db.syncFriendsTableToFirebase();
          await db.cancelRealtimeListeners();
          await db.setupRealtimeListenersOptimized(User.id!);

          // Wait for the listeners to set up, then update user data
          Friend updatedUser = await Friend.getUserObject(User.id!);
          User = updatedUser!;

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Friendship Added Successfully'),
              duration: Duration(seconds: 5),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Refresh Home Page'),
              duration: Duration(seconds: 5),
            ),
          );

          return User.friendlist;
        }
      }
    } catch (e) {
      // Handle any errors that occur during the process
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          duration: Duration(seconds: 5),
        ),
      );
      return User.friendlist;  // Return the original friend list in case of error
    }
  }


  Future<int> generateUniqueFriendId() async {
    DatabaseReference friendsRef = FirebaseDatabase.instance.ref("Friends");
    DataSnapshot snapshot = await friendsRef.get();
    List<int> existingFriendIds = [];

    if (snapshot.exists) {
      if (snapshot.value is Map) {
        // If snapshot.value is a Map, process as a Map
        Map<String, dynamic> friendsMap = Map<String, dynamic>.from(snapshot.value as Map);
        existingFriendIds = friendsMap.keys.map((key) => int.tryParse(key) ?? 0).toList();
      } else if (snapshot.value is List) {
        // If snapshot.value is a List, process as a List
        List<dynamic> friendsList = List<dynamic>.from(snapshot.value as List);
        existingFriendIds = friendsList
            .asMap()
            .entries
            .where((entry) => entry.key != null)
            .map((entry) => int.tryParse(entry.key.toString()) ?? 0)
            .toList();
      } else {
        print("Snapshot contains unknown data type: ${snapshot.value.runtimeType}");
      }
    } else {
      print("Snapshot does not exist or is empty.");
    }

    int index = 1;
    while (existingFriendIds.contains(index)) {
      print(index);
      index++;
    }

    return index;
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

//profile
  pickImage(Friend User,BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final imagebytes = await File(pickedImage.path).readAsBytes();
      String encodedim = base64Encode(imagebytes);

      bool update = await Friend.updateUser(User.id!,"Image",encodedim);
      Friend? updateduser = await Friend.getUserById(User.id!);
      User=updateduser!;
      db.syncUsersTableToFirebase();
        //return File(pickedImage.path);
      return User;

    }
  }
//Profile
  NotificationSwitch(Friend User,bool value,BuildContext context)async{
    bool update = await Friend.updateUser(User.id!,"Notifications",(value==false)?0:1);
    Friend? updateduser = await Friend.getUserObject(User.id!);
    User=updateduser!;
    db.syncUsersTableToFirebase();
    return User;

  }

  //Profile
  GoToEventsListFromProfile(int Userid, BuildContext context) async {
    Friend? updateduser = await Friend.getUserObject(Userid);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EventListPage(isOwner: true, User: updateduser),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
    return updateduser;
  }

//Profile
  GoToMyPledgedGifts(int userid, BuildContext context) async {
    List<Gift> plgf = await Friend.getPledgedGiftsWithEventDetails(userid);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MyPledgedGifts(pledgedgifts: plgf),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

//Profile
  SignOut(BuildContext context) async {
    // Remove FCM Token on signout
    await FirebaseMessagingService()
        .removeFCMToken(FirebaseAuth.instance.currentUser!.uid.hashCode);

    // Delete local data on signout
    db.DeleteLocalDataOnSignOut();

    // Cancel listeners
    db.cancelRealtimeListeners();

    // Unauthenticate user
    auth.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SignIn(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
          (Route<dynamic> route) => false,
    );
  }

  AlreadyAuthenticatedUser(int userID)async{
    await db.cancelRealtimeListeners();
    await db.setupRealtimeListenersOptimized(userID);
  }


EditProfileFieldOnSave(int userid,String field,TextEditingController controller,BuildContext context)async{
  bool update = await Friend.updateUser(userid,field,controller.text);
  Friend? updateduser = await Friend.getUserById(userid);
  db.syncUsersTableToFirebase();
  return updateduser;
  }
PopEditCard(BuildContext context)async{
  Navigator.of(context).pop();
}

  SubmitSignInForm(TextEditingController _EmailController, TextEditingController _passwordController, GlobalKey<FormState> _formKey, BuildContext context,) async {
    if (_formKey.currentState!.validate()) {
      final String Email = _EmailController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        // Attempt to sign in using Firebase Authentication
        dynamic user = await auth.signInWithEmailAndPassword(Email, password, context);

        if (user == null) {
          // Show error snackbar if authentication fails
          showCustomSnackBar(context, "Incorrect Email or Password");
          return;
        }

        // Save the FCM token for the authenticated user
        await FirebaseMessagingService().initNotifications(user);

        // final giftNotificationManager = GiftNotificationManager();
        // giftNotificationManager.startListening(user);

        // Add a delay based on the setupRealtimeListenersOptimized result
        int delayInSeconds = await db.setupRealtimeListenersOptimized(user);
        //wait till information fetched from firebase to local database
        print("Starting 10-second delay...");
        await Future.delayed(Duration(seconds: delayInSeconds));
        print("Delay completed. Fetching user object...");
          // Retrieve the authenticated user object
        Friend authenticatedUser = await Friend.getUserObject(user);

        // Navigate to the Home screen and clear navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                Home(User: authenticatedUser),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        // Log error and show a snackbar
        print("Error during sign-in: $e");
        showCustomSnackBar(context, "Something went wrong. Please try again.");
      }
    }
  }



IsUserFound(TextEditingController emailcont,TextEditingController passcont,BuildContext context)async{
  dynamic user = await auth.signInWithEmailAndPassword(emailcont.text, passcont.text,context);

  if(user==null)return false;
  else return true;
}


NavigatetoSignUp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Signup(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
          (Route<dynamic> route) => false,
    );
  }

NavigatetoSignIn(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SignIn(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
          (Route<dynamic> route) => false,
    );
  }


Future<void> SubmitSignUpForm(
    TextEditingController _nameController,
    TextEditingController _emailController,
    TextEditingController _preferencesController,
    TextEditingController _phoneNumberController,
    TextEditingController _passwordController,
    File? _selectedImage,
    BuildContext context,
    GlobalKey<FormState> _formKey) async {

  if (_formKey.currentState!.validate() && _selectedImage!=null) {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String preferences = _preferencesController.text.trim();
    final String phoneNumber = _phoneNumberController.text.trim();
    final String password = _passwordController.text.trim();
    final File? image = _selectedImage;

    final imageBytes = await File(image!.path).readAsBytes();
    String encodedImage = base64Encode(imageBytes);
    print(phoneNumber);
    print(email);
    // Check if the phone number & email already exists in the Firebase Realtime Database
    final databaseRef = FirebaseDatabase.instance.ref('Users');
    final phoneSnapshot = await databaseRef.orderByChild('PhoneNumber').equalTo(phoneNumber).get();
    final Emailsnapshot = await databaseRef.orderByChild('Email').equalTo(email).get();
    print(phoneSnapshot.value);
    if (phoneSnapshot.exists) {
      if(Emailsnapshot.exists)showCustomSnackBar(context, "Email Already Registered");
      showCustomSnackBar(context, "Phone number already registered");
    }
    else if(Emailsnapshot.exists){
      showCustomSnackBar(context, "Email Already Registered");
    }
    else if(password.length < 6){
      showCustomSnackBar(context, "Password is less than 6 characters");
    }
    else {
      try {
        final userRecord = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
        if (userRecord.isNotEmpty) {
          showCustomSnackBar(context, "Email already registered");
        } else if (_selectedImage == null) {
          showCustomSnackBar(context, "No Image Selected");
        } else {
          // Sign up using Firebase Authentication
          dynamic signupstate = await auth.signUpWithEmailPassword(
              name, email, preferences, phoneNumber, password, encodedImage, context
          );

          if (signupstate != null) {
            showCustomSnackBar(context, "Account Registered Successfully!", backgroundColor: Colors.green);
            _nameController.clear();
            _emailController.clear();
            _preferencesController.clear();
            _phoneNumberController.clear();
            _passwordController.clear();
            image.delete();
          }
        }
      } catch (e) {
        //showCustomSnackBar(context, "Error checking email: $e");
      }
    }
  }
  if(_selectedImage==null)showCustomSnackBar(context, "No Image Selected");
}


  refreshFriendsList(int userid) async {
    return await Friend.getUserObject(userid);
  }




}

