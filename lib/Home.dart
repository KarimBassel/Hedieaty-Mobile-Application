import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Database.dart';
import 'package:hedieatymobileapplication/EventList.dart';
import 'package:hedieatymobileapplication/Profile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'FriendCard.dart';
import 'Base Classes/Friend.dart';



class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Databaseclass? db;
  final List<Friend> friends = [
    Friend(
      image:
      'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1729004634~exp=1729005234~hmac=cb0fb1a6e2dd8ce69411b07aecac4347fa1bad93feb2cbbe5070ef06955202d8',
      name: 'Cristiano Ronaldo',
      upev: 'Upcoming Events: 2',
    ),
    Friend(
      image:
      'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1729004634~exp=1729005234~hmac=cb0fb1a6e2dd8ce69411b07aecac4347fa1bad93feb2cbbe5070ef06955202d8',
      name: 'Leonel Messi',
      upev: 'Upcoming Events: 1',
    ),
    Friend(
      image:
      'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1729004634~exp=1729005234~hmac=cb0fb1a6e2dd8ce69411b07aecac4347fa1bad93feb2cbbe5070ef06955202d8',
      name: 'Mohamed Salah',
      upev: 'Upcoming Events: 5',
    ),
  ];


  @override
  void initState() {
    db = Databaseclass();
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
            ),
            SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: SearchBar(
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
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => EventListPage(isOwner: true,)));
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

          ...friends.map((friend) =>
              Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(friend.image!),
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
                        friend.upev!,
                        style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                        ),
                        ),
                      ],
                    ),
                    onTap: () {

                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              EventListPage(isOwner: false,)));
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
            onTap: () {
              setState(() {
                friends.add(
                  Friend(
                    image:
                    'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1729004634~exp=1729005234~hmac=cb0fb1a6e2dd8ce69411b07aecac4347fa1bad93feb2cbbe5070ef06955202d8',
                    name: 'New Friend (From Contacts)',
                    upev: 'Upcoming Events: 1',
                  ),
                );
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
          onPressed: () {
            final name = PhoneController.text;
            setState(() {
              friends.add(
                Friend(
                  image:
                  'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1729004634~exp=1729005234~hmac=cb0fb1a6e2dd8ce69411b07aecac4347fa1bad93feb2cbbe5070ef06955202d8',
                  name: 'Cristiano Ronaldo',
                  upev: 'Upcoming Events: 2',
                  PhoneNumber: PhoneController.text,
                ),
              );
            });

            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  });
}

}