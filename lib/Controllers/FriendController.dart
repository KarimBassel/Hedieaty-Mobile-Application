import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:hedieatymobileapplication/Models/Authentication.dart';
import 'package:image_picker/image_picker.dart';
import '../Models/Database.dart';
import '../Models/Friend.dart';
import '../Models/Gift.dart';
import '../Views/MyPledgedGifts.dart';
import '../Views/Profile.dart';
import '../Views/EventList.dart';
import '../Views/SignIn.dart';
class FriendController {
  final Databaseclass db = Databaseclass();
  final databaseRef = FirebaseDatabase.instance.ref();
  final AuthService auth = AuthService();

//Home
  ProfileIconTap(int userid, BuildContext context) async {
    Friend? uptodate = await Friend.getUserObject(userid);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Profile(User: uptodate)),
    );
  }

  //Home
  CreateEventOnTap(int userid, BuildContext context) async {
    Friend user = await Friend.getUserObject(userid);
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => EventListPage(isOwner: true, User: user,)));
  }

//Home
  FriendCardOnTap(int friendid, Friend user, BuildContext context) async {
    Friend friend = await Friend.getUserObject(friendid);
    Navigator.push(context, MaterialPageRoute(
        builder: (context) =>
            EventListPage(isOwner: false, User: user, friend: friend)));
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
        Friend updatedUser = await Friend.getUserObject(User.id!);

        await db!.syncFriendsTableToFirebase();
        User=updatedUser!;
        return User.friendlist;
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
GoToEventsListFromProfile(int Userid,BuildContext context)async{
  Friend? updateduser = await Friend.getUserObject(Userid);
  Navigator.push(context, MaterialPageRoute(builder: (context) => EventListPage(isOwner: true,User: updateduser,)));
  return updateduser;
}
//Profile
GoToMyPledgedGifts(int userid,BuildContext context)async{
  List<Gift> plgf = await Friend.getPledgedGiftsWithEventDetails(userid);
  Navigator.push(context, MaterialPageRoute(builder: (context) => MyPledgedGifts(pledgedgifts:plgf)));
}
//Profile
SignOut(BuildContext context){
  auth.signOut();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => SignIn()),
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




}

