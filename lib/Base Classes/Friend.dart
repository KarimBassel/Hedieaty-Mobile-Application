import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Database.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Event.dart';
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
    print(map["Notifications"]);
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
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences,
      'upev': upev,
      'image': image,
      'phone': PhoneNumber,
    };
  }

  static Future<dynamic> getuser(String phone, String pass) async {
    final db = await Databaseclass();

    List<Map<String, dynamic>> response = await db.readData(
        "SELECT * FROM Users WHERE PhoneNumber='${phone}' and Password='${pass}'");

    if(response.isEmpty)return false;
    else return Friend.fromMap(response[0]);
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

  static Future<List<Event>> getEvents(var userID) async {
    final db = await Databaseclass();

    // Step 1: Retrieve the events associated with the UserID
    List<Map<String, dynamic>> eventsResponse = await db.readData(
        "SELECT * FROM Events WHERE UserID='${userID}'"
    );
    print(eventsResponse.isEmpty);

    // Step 2: Create a list to hold Event objects
    List<Event> eventsList = [];
    if (eventsResponse.isEmpty) return eventsList;

    // Step 3: Convert the events data to Event objects
    for (var eventData in eventsResponse) {
      Event event = Event.fromMap(eventData);

      // Step 4: Retrieve the gifts associated with the event
      List<Map<String, dynamic>> giftsResponse = await db.readData(
          "SELECT * FROM Gifts WHERE EventID=${event.id}"
      );

      // Step 5: Create a list to hold Gift objects for the event
      List<Gift> giftsList = [];
      if (giftsResponse.isNotEmpty) {
        // Convert gift data to Gift objects and add them to the list
        for (var giftData in giftsResponse) {
          Gift gift = Gift.fromMap(giftData);
          giftsList.add(gift);
        }
      }

      // Step 6: Add the gifts list to the event
      event.giftlist = giftsList;

      // Add the event to the list of events
      eventsList.add(event);
    }

    // Step 7: Return the list of events with their associated gifts
    return eventsList;
  }




  static Future<dynamic> registerFriend(int userID, String friendPhone) async {
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
        return false; // Friend not found
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

  static Future<Friend> getUserById(int id) async {
    final db = await Databaseclass();


      // Step 1: Fetch the user
      String userQuery = "SELECT * FROM Users WHERE ID = $id";
      List<Map<String, dynamic>> userResult = await db.readData(userQuery);

      if (userResult.isEmpty) {
        print("No user found with ID: $id");
         // No user found
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
      // Step 1: Get the database instance
      final db = await Databaseclass();

      // Step 2: Query to fetch pledged gifts with event details and owner name
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

      // Step 3: Execute the query
      List<Map<String, dynamic>> result = await db.readData(query);

      // Step 4: Create a list to hold Gift objects
      List<Gift> giftsList = [];

      // Step 5: Process each record and map it to a Gift object
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

    // Step 1: Fetch the user based on the phone number
    String userQuery = "SELECT * FROM Users WHERE PhoneNumber = '$phoneNumber'";
    List<Map<String, dynamic>> userResult = await db.readData(userQuery);

    if (userResult.isEmpty) {
      // If no user is found with the given phone number, return false
      return false;
    }

    // Step 2: If user is found, return true
    return true;
  }


  void showCustomSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.red}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.error_outline,  // Customize the icon
            color: Colors.white,
          ),
          SizedBox(width: 8), // Add some space between the icon and the text
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,  // Ensure the text doesn't overflow
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,  // Set the background color
      duration: Duration(seconds: 3), // Duration the SnackBar will be shown
      behavior: SnackBarBehavior.floating, // Makes the SnackBar float above other widgets
      margin: EdgeInsets.all(16),  // Add some margin around the SnackBar
      shape: RoundedRectangleBorder(  // Rounded corners for the SnackBar
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


}