import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'FriendCard.dart';




class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{
  final List<Map<String, String>> friends = [
    {
      'imageUrl':
      'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1729004634~exp=1729005234~hmac=cb0fb1a6e2dd8ce69411b07aecac4347fa1bad93feb2cbbe5070ef06955202d8',
      'name': 'Cristiano Ronaldo',
      'eventStatus': 'Upcoming Events: 2',
    },
    {
      'imageUrl':
      'https://img.freepik.com/premium-psd/man-with-beard-mustache-stands-front-white-background_1233986-1241.jpg',
      'name': 'Leonel Messi',
      'eventStatus': 'No Upcoming Events',
    },
    {
      'imageUrl':
      'https://img.freepik.com/free-photo/headshot-attractive-man-smiling-pleased-looking-intrigued-standing-blue-background_1258-65733.jpg?w=1060&t=st=1729004724~exp=1729005324~hmac=d4b3ea4ca32703e4beceb1d315a56d3d817890879c6cb523591fa770fde90195',
      'name': 'Mohamed Salah',
      'eventStatus': 'Upcoming Events: 1',
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(
            "Homepage",
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
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
                        "Create your own Event/List",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Dynamic Card Generation
                  ...friends.map((friend) => Column(
                    children: [
                      FriendsCard(
                        imageUrl: friend['imageUrl']!,
                        name: friend['name']!,
                        eventStatus: friend['eventStatus']!,
                      ),
                      SizedBox(height: 10),
                    ],
                  )),

                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {

            friends.add({
              'imageUrl':
              'https://img.freepik.com/premium-psd/man-with-beard-mustache-stands-front-white-background_1233986-1241.jpg',
              'name': 'New Friend',
              'eventStatus': 'Upcoming Events: 0',
            });

          });

        },
        tooltip: 'Add Friend',
        child: const Icon(Icons.add),
      ),
    );
  }
}