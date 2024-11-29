import 'dart:convert';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Database.dart';
import 'package:hedieatymobileapplication/EventList.dart';
import 'package:hedieatymobileapplication/Profile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'FriendCard.dart';
import 'Base Classes/Friend.dart';
import 'Base Classes/Event.dart';
//import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';


class Home extends StatefulWidget {
  Friend User;
  Home({required this.User});

  @override
  _HomeState createState() => _HomeState();


}

class _HomeState extends State<Home> {
  Databaseclass? db;
  List<Friend>? filteredfriends;
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();


  @override
  void initState() {
    db = Databaseclass();
    filteredfriends=widget.User.friendlist;
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:  AppBar(

        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.account_circle),
              tooltip: "My Profile",
              iconSize: 35,
              onPressed: ()async {
                Friend? uptodate = await Friend.getUserObject(widget.User.id!);
                widget.User=uptodate!;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile(User:widget.User)),
                );
              },
            ),
            SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: SearchBar(
                  onChanged: (val){
                    _filterFriends(val);
                  },
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),

                  leading: const Icon(
                    Icons.search,

                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: ()async {
                widget.User = await Friend.getUserObject(widget.User.id!);
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => EventListPage(isOwner: true,User: widget.User,)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
              child: Text(
                "Create your own Event",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          ...filteredfriends!.map((friend) =>
              Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: MemoryImage(base64Decode(friend.image!.split(',').last)),
                    ),
                    title: Text(
                      friend.name!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Upcoming Events: ${friend.upev??0}',
                        style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                        ),
                        ),
                      ],
                    ),
                    onTap: () async{
                      friend = await Friend.getUserObject(friend.id!);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              EventListPage(isOwner: false,User: widget.User,friend:friend)));
                    },
                  ),
                  Divider(),
                ],
              )),
        ],
      ),
      floatingActionButton: PopupMenuButton<String>(
        tooltip: "Add Friend",
        icon: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.orangeAccent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: 'manual',
            child: Text('Add Friend Manually'),
            onTap: showFriendDialogue,
          ),
          PopupMenuItem(
            value: 'contacts',
            child: Text('Add Friend from Contacts'),
            onTap: () async {

              Contact? contact = await _contactPicker.selectContact();
              String ExtractedNumber = contact!.phoneNumbers
                  .toString()
                  .replaceAll(RegExp(r'[\[\]]'), '')
                  .replaceFirst('+2', '');
              //print(ExtractedNumber);
              if(widget.User.PhoneNumber==ExtractedNumber)showCustomSnackBar(context,"Cannot Add Yourself");
              else {
                dynamic newfriend = await Friend.registerFriend(widget.User.id!, ExtractedNumber);
                if (newfriend is bool) {
                  showCustomSnackBar(context, "User Not Found");
                }
                else {
                  Friend updatedUser = await Friend.getUserObject(widget.User.id!);
                  widget.User = updatedUser!;
                  filteredfriends = widget.User.friendlist;
                }
              }
              setState(() {

              });
            },
          ),
        ],
      )



    );
  }

  void showFriendDialogue(){
  final PhoneController = TextEditingController();

  
  showDialog(context: context, builder: (BuildContext context){
    return AlertDialog(
      title: Text("Add Friend Manually"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: PhoneController,
            decoration: InputDecoration(labelText: 'Enter Phone Number'),
          ),

        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: ()async {
            print(widget.User.id!);
            final phone = PhoneController.text;
            if(widget.User.PhoneNumber==phone)showCustomSnackBar(context,"Cannot Add Yourself");
            else{
              dynamic newfriend = await Friend.registerFriend(widget.User.id!, phone);
              //returned false from search query of the phone number
              if(newfriend is bool){
                showCustomSnackBar(context,"User Not Found");
              }
              else{
                Friend updatedUser = await Friend.getUserObject(widget.User.id!);
                await db!.syncFriendsTableToFirebase();
                widget.User=updatedUser!;
                filteredfriends = widget.User.friendlist;
              }
            }

            setState(() {

            });
            await db!.syncFriendsTableToFirebase();
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  });
}
  void _filterFriends(String query) {
    final filtered = widget.User.friendlist!.where((friend) {
      return friend.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredfriends = filtered;
    });
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