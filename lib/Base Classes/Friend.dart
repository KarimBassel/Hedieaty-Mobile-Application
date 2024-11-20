import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Database.dart';

class Friend {
  int? id;
  String name;
  String? email;
  String? preferences;
  int? upev;
  String? image;
  String? PhoneNumber;
  String? password;
  bool? notifications;
  List<Friend>? friendlist;

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
    //print(map["Name"]);
    return Friend(
      id: map['ID'],
      name: map['Name'],
      email: map['Email'],
      preferences: map['Preferences'],
      upev: map["upev"],
      image: map['Image'],
      PhoneNumber: map['PhoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences,
      'upev': upev,
      'image': image,
      'phone': PhoneNumber,
    };
  }

  static Future<Friend> getuser(String phone, String pass) async {
    final db = await Databaseclass();

    List<Map<String, dynamic>> response = await db.readData(
        "SELECT * FROM Users WHERE PhoneNumber='${phone}' and Password='${pass}'");

    return Friend.fromMap(response[0]);
  }

  static Future<List<Friend>> getFriends(var userID) async {
    final db = await Databaseclass();

    // Step 1: Get FriendIDs associated with the UserID
    List<Map<String, dynamic>> friendIDsResponse = await db.readData(
        "SELECT FriendID FROM Friends WHERE UserID='${userID}'");

    // Step 2: Extract FriendIDs from the response
    List<int> friendIDs = [];
    for (var friend in friendIDsResponse) {
      friendIDs.add(
          friend['FriendID'] as int); // Assuming 'FriendID' is the field name
    }


    // Step 3: Retrieve user data for each FriendID and count upcoming events
    List<Friend> friendsList = [];
    if (friendIDs.isEmpty) return friendsList;
    for (var friendID in friendIDs) {
      // Retrieve friend data
      List<Map<String, dynamic>> userDataResponse = await db.readData(
          "SELECT * FROM Users WHERE ID='${friendID}'");

      // Step 4: Convert each result to a Friend object and add to the list
      if (userDataResponse.isNotEmpty) {
        Friend friend = Friend.fromMap(userDataResponse[0]);

        // Step 5: Get the count of upcoming events for each friend
        List<Map<String, dynamic>> eventCountResponse = await db.readData(
            "SELECT COUNT(*) as eventCount FROM Events WHERE UserID='${friendID}' AND date > '${DateTime
                .now().toIso8601String()}'");

        // Step 6: Set the count of upcoming events in the friend object
        if (eventCountResponse.isNotEmpty) {
          friend.upev = eventCountResponse[0]['eventCount'] as int;
        }

        // Add friend to the list
        friendsList.add(friend);
      }
    }

    // Step 7: Return the list of friends with the count of upcoming events
    return friendsList;
  }

  static Future<Friend?> registerFriend(int userID, String friendPhone) async {
    final db = await Databaseclass();

    try {
      // Step 1: Get the FriendID based on the friend's phone number
      List<Map<String, dynamic>> friendResponse = await db.readData(
          "SELECT * FROM Users WHERE PhoneNumber = '$friendPhone'");

      // Step 2: Check if the friend exists and extract the FriendID
      if (friendResponse.isNotEmpty) {
        int friendID = friendResponse[0]['ID'];

        // Step 3: Insert the UserID and FriendID into the Friends table
        String query =
            "INSERT INTO Friends (UserID, FriendID) VALUES ($userID, $friendID)";

        // Step 4: Execute the insertion
        var result = await db.insertData(query);
          // If insertion was successful, create a Friend object and return it
          return Friend.fromMap(friendResponse[0]);

      } else {
        print('Friend with phone number $friendPhone not found.');
        return null; // Friend not found
      }
    } catch (e) {
      // Catch any errors
      print("Error while registering friend: $e");
      return null; // Something went wrong
    }
  }

  static Future<bool> updateUser(int id, String field, dynamic value) async {
    final db = await Databaseclass();

    try {
      // Validate field and value
      if (field.isEmpty || value == null) {
        print("Field or value cannot be empty.");
        return false;
      }

      // Sanitize the value (if it's a string, wrap it in quotes)
      String sanitizedValue = value is String ? "'$value'" : value.toString();

      // Construct the SQL query
      String query = "UPDATE Users SET $field = $sanitizedValue WHERE ID = $id";

      // Execute the query
      int result = await db.updateData(query);

      // Check if any rows were affected
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

  static Future<Friend?> getUserById(int id) async {
    final db = await Databaseclass();

    try {
      // Step 1: Fetch the user
      String userQuery = "SELECT * FROM Users WHERE ID = $id";
      List<Map<String, dynamic>> userResult = await db.readData(userQuery);

      if (userResult.isEmpty) {
        print("No user found with ID: $id");
        return null; // No user found
      }

      // Convert the user data to a Friend object
      Friend user = Friend.fromMap(userResult[0]);

      // Step 2: Fetch the user's friends
      String friendsQuery = "SELECT FriendID FROM Friends WHERE UserID = $id";
      List<Map<String, dynamic>> friendsResult = await db.readData(friendsQuery);

      // Populate the user's friends list
      List<Friend> friends = [];
      for (var friendData in friendsResult) {
        int friendID = friendData['FriendID'];
        String friendDetailsQuery = "SELECT * FROM Users WHERE ID = $friendID";
        List<Map<String, dynamic>> friendDetails = await db.readData(friendDetailsQuery);

        if (friendDetails.isNotEmpty) {
          friends.add(Friend.fromMap(friendDetails[0]));
        }
      }

      // Assign the list of friends to the user
      user.friendlist = friends;

      return user;
    } catch (e) {
      print("Error fetching user and their friends: $e");
      return null; // Handle error
    }
  }



}