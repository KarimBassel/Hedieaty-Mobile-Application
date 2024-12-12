import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:hedieatymobileapplication/FirebaseMessaging.dart';
import 'package:hedieatymobileapplication/Models/Authentication.dart';
import 'package:image_picker/image_picker.dart';
import '../Models/Database.dart';
import '../Models/Friend.dart';
import '../Models/Gift.dart';
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
          // Define the animation (slide in from the bottom)
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
          // Slide from the right
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
          // Slide animation from the right
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
  AddFriendFromContacts(FlutterNativeContactPicker _contactPicker, Friend User,
      BuildContext context) async {
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
        dynamic newfriend = await Friend.registerFriend(
            User.id!, ExtractedNumber);
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
  AddFriendManual(TextEditingController PhoneController,Friend User,BuildContext context)async{
    final phone = PhoneController.text;
    if(User.PhoneNumber==phone)showCustomSnackBar(context,"Cannot Add Yourself");
    else{
      dynamic newfriend = await Friend.registerFriend(User.id!, phone);
      //returned false from search query of the phone number
      if(newfriend is bool){
        showCustomSnackBar(context,"User Not Found");
        Friend updatedUser = await Friend.getUserObject(User.id!);
        return updatedUser.friendlist;
      }
      else{
        await db!.syncFriendsTableToFirebase();
        //Future.delayed(Duration(seconds: 1),()async{
          Friend updatedUser = await Friend.getUserObject(User.id!);


          User=updatedUser!;
          return User.friendlist;
       // });

  }
  }
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
          // Slide animation from the bottom
          const begin = Offset(0.0, 1.0); // Start position: bottom of the screen
          const end = Offset.zero; // End position: original position
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
          const end = Offset.zero; // End position: original position
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


EditProfileFieldOnSave(int userid,String field,TextEditingController controller,BuildContext context)async{
  bool update = await Friend.updateUser(userid,field,controller.text);
  Friend? updateduser = await Friend.getUserById(userid);
  db.syncUsersTableToFirebase();
  return updateduser;
  }
PopEditCard(BuildContext context)async{
  Navigator.of(context).pop();
}

SubmitSignInForm(
    TextEditingController _EmailController,
    TextEditingController _passwordController,
    GlobalKey<FormState> _formKey,
    BuildContext context,
    ) async {
  if (_formKey.currentState!.validate()) {
    final String Email = _EmailController.text.trim();
    final String password = _passwordController.text.trim();

    // Sign in using Firebase Authentication
    dynamic user = await auth.signInWithEmailAndPassword(Email, password);

    // If user not found, show an error snackbar
    if (user == null) {
      showCustomSnackBar(context, "Incorrect Email or Password");
    } else {
      // Save the FCM token for the current user
      await FirebaseMessagingService().initNotifications(user);

      // Sync related rows to user from Firebase
      await db.setupRealtimeListenersOptimized(user);


      Future.delayed(Duration(seconds: 2), () async {
        // Get the authenticated user object from the local database
        Friend authenticatedUser = await Friend.getUserObject(user);
        print(user);

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
              (Route<dynamic> route) => false, // Remove all previous routes
        );
      });
    }
  }
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


SubmitSignUpForm(TextEditingController _nameController,TextEditingController _emailController,
    TextEditingController _preferencesController,TextEditingController _phoneNumberController,
    TextEditingController _passwordController,File? _selectedImage,BuildContext context,GlobalKey<FormState> _formKey)async{

  if (_formKey.currentState!.validate()) {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String preferences = _preferencesController.text.trim();
    final String phoneNumber = _phoneNumberController.text.trim();
    final String password = _passwordController.text.trim();
    final File? image = _selectedImage;

    final imageBytes = await File(image!.path).readAsBytes();
    String encodedImage = base64Encode(imageBytes);

    if (await Friend.getUserByPhoneNumber(phoneNumber)) {
  showCustomSnackBar(context, "Phone number already registered");
  }
    else if(_selectedImage==null){
      showCustomSnackBar(context, "No Image Selected");
    }else {

  //Sign up using Firebase Authentication
  auth.signUpWithEmailPassword(name, email, preferences, phoneNumber, password, encodedImage);

  showCustomSnackBar(context, "Account Registered Successfully!", backgroundColor: Colors.green);
  _nameController.clear();
  _emailController.clear();
  _preferencesController.clear();
  _phoneNumberController.clear();
  _passwordController.clear();
  image.delete();
  //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signup()));
  }
}
}






}

