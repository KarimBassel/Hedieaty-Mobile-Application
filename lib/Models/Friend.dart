import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Models/Database.dart';
import 'package:hedieatymobileapplication/Models/Event.dart';
import 'Gift.dart';

class Friend {
  int? id;
  String name;
  String? email;
  String? preferences;
  int? upev;
  String? image;
  String? PhoneNumber;
  String? password;
  int? notifications;
  List<Friend>? friendlist;
  List<Event>? eventlist;
  List<Gift>? PledgedGifts;

  Friend({
    this.id,
    required this.name,
    this.email,
    this.preferences,
    this.upev,
    this.image,
    this.PhoneNumber,
    this.password,
    this.notifications,
    this.friendlist
  });

  factory Friend.fromMap(Map<String, dynamic> map) {
    //print(map["Notifications"]);
    return Friend(
      id: map['ID'],
      name: map['Name'],
      email: map['Email'],
      preferences: map['Preferences'],
      upev: map["upev"],
      image: map['Image'],
      notifications: map["Notifications"],
      PhoneNumber: map['PhoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'Name': name,
      'Email':email,
      'Preferences': preferences,
      'upev': upev,
      'Image': image,
      'PhoneNumber': PhoneNumber,
      'Notifications':notifications,
    };
  }

  static Future<dynamic> getUser(String email, String pass) async {
    final db = await Databaseclass();

    List<Map<String, dynamic>> response = await db.readData(
        "SELECT * FROM Users WHERE Email='${email}' and Password='${pass}'");

    if (response.isEmpty) return false;

    else return Friend.fromMap(response[0]);
  }


  static Future<List<Friend>> getFriends(var userID) async {
    final db = await Databaseclass();

    List<Map<String, dynamic>> friendIDsResponse = await db.readData(
        "SELECT FriendID FROM Friends WHERE UserID='${userID}'");

    List<int> friendIDs = [];
    for (var friend in friendIDsResponse) {
      friendIDs.add(
          friend['FriendID'] as int);
    }


    List<Friend> friendsList = [];
    if (friendIDs.isEmpty) return friendsList;
    for (var friendID in friendIDs) {
      List<Map<String, dynamic>> userDataResponse = await db.readData(
          "SELECT * FROM Users WHERE ID='${friendID}'");

      if (userDataResponse.isNotEmpty) {
        Friend friend = Friend.fromMap(userDataResponse[0]);

        List<Map<String, dynamic>> eventCountResponse = await db.readData(
            "SELECT COUNT(*) as eventCount FROM Events WHERE UserID='${friendID}' AND date > '${DateTime
                .now().toIso8601String()}'");

        if (eventCountResponse.isNotEmpty) {
          friend.upev = eventCountResponse[0]['eventCount'] as int;
        }

        friendsList.add(friend);
      }
    }

    return friendsList;
  }

  static Future<List<Event>> getEvents(var userID) async {
    final db = await Databaseclass();

    List<Map<String, dynamic>> eventsResponse = await db.readData(
        "SELECT * FROM Events WHERE UserID='${userID}'"
    );
    print(eventsResponse.isEmpty);
    List<Event> eventsList = [];
    if (eventsResponse.isEmpty) return eventsList;
    for (var eventData in eventsResponse) {
      Event event = Event.fromMap(eventData);
      List<Map<String, dynamic>> giftsResponse = await db.readData(
          "SELECT * FROM Gifts WHERE EventID=${event.id}"
      );
      List<Gift> giftsList = [];
      if (giftsResponse.isNotEmpty) {
        for (var giftData in giftsResponse) {
          Gift gift = Gift.fromMap(giftData);
          giftsList.add(gift);
        }
      }
      event.giftlist = giftsList;
      eventsList.add(event);
    }
    return eventsList;
  }




  // static Future<dynamic> registerFriend(int userID, String friendPhone) async {
  //   final db = await Databaseclass();
  //
  //   try {
  //     List<Map<String, dynamic>> friendResponse = await db.readData(
  //         "SELECT * FROM Users WHERE PhoneNumber = '$friendPhone'");
  //
  //     if (friendResponse.isNotEmpty) {
  //       int friendID = friendResponse[0]['ID'];
  //
  //       String query =
  //           "INSERT INTO Friends (UserID, FriendID) VALUES ($userID, $friendID)";
  //
  //       var result = await db.insertData(query);
  //       return Friend.fromMap(friendResponse[0]);
  //
  //     } else {
  //       print('Friend with phone number $friendPhone not found.');
  //       return false;
  //     }
  //   } catch (e) {
  //
  //     print("Error while registering friend: $e");
  //     return null;
  //   }
  // }


  //fetch intended user from firebase if exists and make new friendship
  static Future<dynamic> registerFriend(int userID, String friendPhone,int id) async {
    final db = await Databaseclass(); // Ensure this function initializes the database correctly
    final databaseRef = FirebaseDatabase.instance.ref();

    try {
      // Step 1: Search in Firebase for the user with the given phone number
      DataSnapshot snapshot = await databaseRef.child('Users').get();

      if (snapshot.value != null && snapshot.value is Map) {
        // Casting snapshot data as Map for easier traversal
        Map<String, dynamic> users = Map<String, dynamic>.from(snapshot.value as Map);

        for (var user in users.entries) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(user.value);

          // Compare the phone number to find the friend
          if (userData['PhoneNumber'] == friendPhone) {
            int friendID = userData['ID'];

            // SQL query to insert into the local database
            String query = "INSERT INTO Friends (ID,UserID, FriendID) VALUES ($id,$userID, $friendID)";
            var result = await db.insertData(query);

            print("Friend added to local database using Firebase data.");

            // Return the friend's information as a Friend object
            return Friend.fromMap(userData);
          }
        }

        // If no user matches the provided phone number
        print("No user found with the phone number: $friendPhone");
        return false;
      } else {
        print("No data found in Firebase for Users.");
        return false;
      }
    } catch (e) {
      // Log and return null on error
      print("Error while registering friend: $e");
      return null;
    }
  }



  static Future<bool> updateUser(int id, String field, dynamic value) async {
    final db = await Databaseclass();

    try {
      if (field.isEmpty || value == null) {
        print("Field or value cannot be empty.");
        return false;
      }
      String sanitizedValue = value is String ? "'$value'" : value.toString();
      String query = "UPDATE Users SET $field = $sanitizedValue WHERE ID = $id";
      int result = await db.updateData(query);
      if (result > 0) {
        print("User updated successfully.");
        return true;
      } else {
        print("No rows were updated.");
        return false;
      }
    } catch (e) {
      print("Error updating user: $e");
      return false;
    }
  }

  static Future<Friend> getUserById(int id) async {
    final db = await Databaseclass();

      String userQuery = "SELECT * FROM Users WHERE ID = $id";
      List<Map<String, dynamic>> userResult = await db.readData(userQuery);

      if (userResult.isEmpty) {
        print("No user found with ID: $id");
      }

      Friend user = Friend.fromMap(userResult[0]);

      String friendsQuery = "SELECT FriendID FROM Friends WHERE UserID = $id";
      List<Map<String, dynamic>> friendsResult = await db.readData(friendsQuery);

      List<Friend> friends = [];
      for (var friendData in friendsResult) {
        int friendID = friendData['FriendID'];
        String friendDetailsQuery = "SELECT * FROM Users WHERE ID = $friendID";
        List<Map<String, dynamic>> friendDetails = await db.readData(friendDetailsQuery);

        if (friendDetails.isNotEmpty) {
          friends.add(Friend.fromMap(friendDetails[0]));
        }
      }
      user.friendlist = friends;

      return user;

  }
  static Future<Friend> getUserObject(int UserID)async{
    final db = await Databaseclass();
    Friend user = await Friend.getUserById(UserID);
    List<Friend> friendlist = await Friend.getFriends(UserID);
    user.friendlist = friendlist;
    List<Event> eventlist = await Friend.getEvents(UserID);
    user.eventlist = eventlist;
    List<Gift> pledgedgifts = await Friend.getPledgedGiftsWithEventDetails(UserID);
    user.PledgedGifts = pledgedgifts;
    return user;

  }
  static Future<List<Gift>> getPledgedGiftsWithEventDetails(int pledgerId) async {
    try {
      final db = await Databaseclass();

      String query = '''
      SELECT 
        Gifts.*, 
        Events.Date AS EventDate, 
        Users.Name AS EventOwnerName
      FROM Gifts
      JOIN Events ON Gifts.EventID = Events.ID
      JOIN Users ON Events.UserID = Users.ID
      WHERE Gifts.PledgerID = $pledgerId
    ''';

      List<Map<String, dynamic>> result = await db.readData(query);

      List<Gift> giftsList = [];

      for (var giftData in result) {
        Gift gift = Gift.fromMap(giftData);
        gift.DueDate = DateTime.parse(giftData['EventDate']);
        gift.Ownername = giftData['EventOwnerName'];
        giftsList.add(gift);
      }

      return giftsList;
    } catch (e) {
      print("Error fetching pledged gifts with event details: $e");
      return [];
    }
  }


  static Future<bool> getUserByPhoneNumber(String phoneNumber) async {
    final db = await Databaseclass();

    String userQuery = "SELECT * FROM Users WHERE PhoneNumber = '$phoneNumber'";
    List<Map<String, dynamic>> userResult = await db.readData(userQuery);

    if (userResult.isEmpty) {
      return false;
    }

    return true;
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