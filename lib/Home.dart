import 'dart:ui';
import 'package:flutter/material.dart';
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

class _HomeState extends State<Home>{
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
      name: 'Cristiano Ronaldo',
      upev: 'Upcoming Events: 2',
    ),
    Friend(
      image:
      'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1729004634~exp=1729005234~hmac=cb0fb1a6e2dd8ce69411b07aecac4347fa1bad93feb2cbbe5070ef06955202d8',
      name: 'Cristiano Ronaldo',
      upev: 'Upcoming Events: 2',
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.account_circle),
              iconSize: 35,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
            ),
            Spacer(),
            Text(
              "Homepage",
              style: TextStyle(fontSize: 25),
            ),
            Spacer(),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          SearchBar(
            padding: const MaterialStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0)),
            leading: const Icon(Icons.search),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EventListPage(isOwner: true,)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan, // Button background color
                padding: EdgeInsets.symmetric(vertical: 15), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
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

          // Dynamic ListTile Generation
          ...friends.map((friend) => Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(friend.image!),
                ),
                title: Text(
                  friend.name!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(friend.upev!),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EventListPage(isOwner: false,)));
                },
              ),
              Divider(), // Optional divider between each item
            ],
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            friends.add(
              Friend(
                image:
                'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1729004634~exp=1729005234~hmac=cb0fb1a6e2dd8ce69411b07aecac4347fa1bad93feb2cbbe5070ef06955202d8',
                name: 'Cristiano Ronaldo',
                upev: 'Upcoming Events: 2',
              ),
            );
          });
        },
        tooltip: 'Add Friend',
        child: const Icon(Icons.add),
      ),
    );
  }


}