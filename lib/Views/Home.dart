import 'dart:convert';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:hedieatymobileapplication/Controllers/FriendController.dart';
import 'package:hedieatymobileapplication/Database.dart';
import 'package:hedieatymobileapplication/Views/EventList.dart';
import 'package:hedieatymobileapplication/Views/Profile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import '../Models/Friend.dart';
import '../Models/Event.dart';
//import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';


class Home extends StatefulWidget {
  Friend User;

  Home({required this.User});

  @override
  _HomeState createState() => _HomeState();


}

class _HomeState extends State<Home> {

  List<Friend>? filteredfriends;
  final FriendController controller = FriendController();
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();


  @override
  void initState() {
    filteredfriends=widget.User.friendlist;
  }


  @override
  Widget build(BuildContext context) {
    filteredfriends = widget.User.friendlist;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.account_circle),
              tooltip: "My Profile",
              iconSize: 35,
              onPressed: () async {
                await controller.ProfileIconTap(widget.User.id!, context);
              },
            ),
            SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: SearchBar(
                  onChanged: (val) {
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
            IconButton(
              icon: Icon(Icons.refresh),
              tooltip: "Refresh Friends List",
              onPressed: () async {
                widget.User = await controller.refreshFriendsList(widget.User.id!);
                setState(() {
                  filteredfriends = widget.User.friendlist;
                });
              },
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
              onPressed: () async {
                await controller.CreateEventOnTap(widget.User.id!, context);
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
          if(filteredfriends!=null)
          ...filteredfriends!.map((friend) => Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                  MemoryImage(base64Decode(friend.image!.split(',').last)),
                ),
                title: Text(
                  friend.name!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Upcoming Events: ${friend.upev ?? 0}',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  await controller.FriendCardOnTap(
                      friend.id!, widget.User, context);
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
            onTap: (){
              showFriendDialogue();

          },
          ),
          PopupMenuItem(
            value: 'contacts',
            child: Text('Add Friend from Contacts'),
            onTap: () async {
              filteredfriends = await controller.AddFriendFromContacts(
                  _contactPicker, widget.User, context);
              Future.delayed(Duration(seconds: 5), () {
                setState(() {});
              });
            },
          ),
        ],
      ),
    );
  }



  void showFriendDialogue() {
    final PhoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Builder(
          builder: (BuildContext innerContext) { // Use a new context for the dialog
            return AlertDialog(
              title: Text("Add Friend Manually"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    keyboardType: TextInputType.phone,
                    controller: PhoneController,
                    decoration: InputDecoration(
                      labelText: 'Enter Phone Number',
                      prefixText: '+20 ', // Add the constant prefix here
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Only allow digits after +20
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close the dialog when Cancel is pressed
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Show a snackbar within the dialog
                    ScaffoldMessenger.of(innerContext).showSnackBar(
                      SnackBar(
                        content: Text('Please wait while we add the friend...'),
                        duration: Duration(seconds: 5), // Show during the async operation
                      ),
                    );

                    // Perform the async operation
                    filteredfriends = await controller.AddFriendManual(
                      PhoneController,
                      widget.User,
                      innerContext,
                    );

                    // After the operation, close the dialog and update UI
                    if (mounted) {
                      setState(() {});
                    }


                    // Close the dialog after a short delay
                    await Future.delayed(Duration(seconds: 1));
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _filterFriends(String query) {
    final filtered = widget.User.friendlist!.where((friend) {
      return friend.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredfriends = filtered;
    });
  }


}