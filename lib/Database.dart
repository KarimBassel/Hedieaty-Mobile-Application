import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:hedieatymobileapplication/Models/Event.dart';
import 'package:hedieatymobileapplication/Models/Friend.dart';
import 'package:hedieatymobileapplication/Models/Gift.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Databaseclass {
  static Database? _MyDataBase;
  StreamSubscription? friendsSubscription;
  StreamSubscription? usersAddedSubscription;
  StreamSubscription? usersChangedSubscription;
  StreamSubscription? usersRemovedSubscription;
  StreamSubscription? eventsAddedSubscription;
  StreamSubscription? eventsChangedSubscription;
  StreamSubscription? eventsRemovedSubscription;
  StreamSubscription? giftsAddedSubscription;
  StreamSubscription? giftsChangedSubscription;
  StreamSubscription? giftsRemovedSubscription;
  StreamSubscription? BarcodeGiftsSubscription;
  Future<Database?> get MyDataBase async {
    if (_MyDataBase == null) {
      print("Okshhhhhhhhhhhhh");
      _MyDataBase = await initialize();
      return _MyDataBase;
    } else {
      return _MyDataBase;
    }
  }

  int Version = 1;

  initialize() async {
    //await mydeletedatabase();
    String mypath = await getDatabasesPath();
    print(mypath);
    String path = join(mypath, 'hedieaty.db');
    Database mydb = await openDatabase(path, version: Version,
        onCreate: (db, Version) async {
      print("KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK");
          db.execute('''
                  CREATE TABLE Users (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  Name TEXT NOT NULL,
  Email TEXT UNIQUE,
  Preferences TEXT,
  PhoneNumber TEXT NOT NULL,
  Password TEXT,
  Image TEXT,
  Notifications BOOLEAN DEFAULT 0,
  UpcomingEvents INTEGER DEFAULT 0
);
''');
              db.execute('''
              CREATE TABLE Events (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  Name TEXT NOT NULL,
  Date TEXT NOT NULL,
  Location TEXT,
  Description TEXT,
  Category TEXT,
  Status TEXT,
  UserID INTEGER NOT NULL,
  FOREIGN KEY (UserID) REFERENCES Users(ID)
);
              ''');

db.execute('''
CREATE TABLE Gifts (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  Name TEXT NOT NULL,
  Description TEXT,
  Category TEXT,
  Price INTEGER,
  Image TEXT,
  Status INTEGER DEFAULT 0,
  EventID INTEGER NOT NULL,
  PledgerID INTEGER DEFAULT -1,
  UserID INTEGER NOT NULL,
  IsPublished INTEGER DEFAULT 0,
  FOREIGN KEY (EventID) REFERENCES Events(ID),
  FOREIGN KEY (PledgerID) REFERENCES Users(ID)
);

''');
      db.execute('''
CREATE TABLE BarcodeGifts (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  Name TEXT NOT NULL,
  Description TEXT,
  Category TEXT,
  Price INTEGER,
  Image TEXT,
  Barcode TEXT
);
''');


db.execute('''
CREATE TABLE Friends (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  UserID INTEGER NOT NULL,
  FriendID INTEGER NOT NULL,
  FOREIGN KEY (UserID) REFERENCES Users(ID),
  FOREIGN KEY (FriendID) REFERENCES Users(ID)
);
''');



      db.execute('''INSERT INTO Events (Name, Date, Location, Description, Category, Status, UserID) VALUES
  ('Birthday Party', '2024-12-15', 'Johns House', 'A fun celebration with friends and family', 'Birthday','Upcoming', 1),
  ('Wedding Anniversary', '2024-11-30', 'Janes House', 'Celebrating our special day', 'Anniversary', 'Upcoming',1),
  ('Tech Conference', '2024-10-25', 'Convention Center', 'A conference on the latest tech trends', 'Completed', 'Completed',1),
  ('Art Exhibition', '2024-09-20', 'Art Gallery', 'An exhibition showcasing local artists', 'Completed', 'Completed',1);
''');






          print("Database has been created .......");
        });
    return mydb;
  }

  readData(String SQL) async {
    Database? mydata = await MyDataBase;
    return  await mydata!.rawQuery(SQL);

  }

  insertData(String SQL) async {
    Database? mydata = await MyDataBase;
    int response = await mydata!.rawInsert(SQL);
    return response;
  }

  deleteData(String SQL) async {
    Database? mydata = await MyDataBase;
    int response = await mydata!.rawDelete(SQL);
    return response;
  }

  updateData(String SQL) async {
    Database? mydata = await MyDataBase;
    int response = await mydata!.rawUpdate(SQL);
    return response;
  }

  mydeletedatabase() async {
    String database = await getDatabasesPath();
    String Path = join(database, 'hedieaty.db');
    bool ifitexist = await databaseExists(Path);
    if (ifitexist == true) {
      print('it exist');
    } else {
      print("it doesn't exist");
    }
    await deleteDatabase(Path);
    print("MyData has been deleted");
  }




setupRealtimeListenersOptimized(int userID) async {
    Database? db = await MyDataBase;
    final databaseRef = FirebaseDatabase.instance.ref();

    final List<int> friendIds = [];
    int delay;
    final friendsDataSnapshot = await databaseRef.child('Friends').get();
    if (friendsDataSnapshot.value is List) {
      final friendsData = friendsDataSnapshot.value as List;
      for (int i = 0; i < friendsData.length; i++) {
        final value = friendsData[i];
        if (value is Map && value['UserID'] == userID) {
          int friendId = value['FriendID'];
          friendIds.add(friendId);

          db!.insert('Friends', {
            'UserID': value['UserID'],
            'FriendID': value['FriendID'],
            'ID': i,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      print("Initial friends list cached: $friendIds");
    }

    // onChildAdded listener for the Friends node
    friendsSubscription = databaseRef.child('Friends').onChildAdded.listen((event) async {
      var friendData = event.snapshot.value;
      if (friendData is Map && friendData['UserID'] == userID) {
        int friendID = friendData['FriendID'];

        if (!friendIds.contains(friendID)) {
          friendIds.add(friendID);

          await db!.insert('Friends', {
            'UserID': friendData['UserID'],
            'FriendID': friendData['FriendID'],
            'ID': event.snapshot.key,
          }, conflictAlgorithm: ConflictAlgorithm.replace);

          print("New friend detected and cached: FriendID = $friendID");
          //await fetchAndSyncFriendData(friendID, db, databaseRef);
        }
      }
    });

    // onChildUpdated listener for the Friends node
    databaseRef.child('Friends').onChildChanged.listen((event) async {
      var updatedFriendData = event.snapshot.value;
      if (updatedFriendData is Map && updatedFriendData['UserID'] == userID) {
        int friendID = updatedFriendData['FriendID'];
        await db!.update('Friends', {
          'UserID': updatedFriendData['UserID'],
          'FriendID': updatedFriendData['FriendID'],
          'ID': event.snapshot.key,
        });
        print("Friend updated and cached: FriendID = $friendID");
      }
    });

    // onChildRemoved listener for the Friends node
    databaseRef.child('Friends').onChildRemoved.listen((event) async {
      var removedFriendData = event.snapshot.value;
      if (removedFriendData is Map && removedFriendData['UserID'] == userID) {
        int friendID = removedFriendData['FriendID'];
        await db!.delete('Friends', where: 'FriendID = ?', whereArgs: [friendID]);
        print("Friend removed from local cache: FriendID = $friendID");
      }
    });

    // onChildAdded listener for the Users node
    usersAddedSubscription = databaseRef.child('Users').onChildAdded.listen((event)async {
      var usersMap = event.snapshot.value;
      if (usersMap is Map && (usersMap['ID'] == userID || friendIds.contains(usersMap['ID']))) {
        await db!.insert('Users', {
          'ID': usersMap['ID'],
          'Name': usersMap['Name'],
          'Email': usersMap['Email'],
          'Preferences': usersMap['Preferences'],
          'PhoneNumber': usersMap['PhoneNumber'],
          'Password': usersMap['Password'],
          'Image': usersMap['Image'],
          'Notifications': usersMap['Notifications'] ?? 0,
          'UpcomingEvents': usersMap['UpcomingEvents'] ?? 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        print("User Added/Updated from Firebase to local");
      }
    });

    // onChildUpdated listener for the Users node
    usersChangedSubscription=databaseRef.child('Users').onChildChanged.listen((event) async {
      var updatedUserData = event.snapshot.value;
      if (updatedUserData is Map && (updatedUserData['ID'] == userID || friendIds.contains(updatedUserData['ID']))) {
        await db!.update('Users', {
          'ID': updatedUserData['ID'],
          'Name': updatedUserData['Name'],
          'Email': updatedUserData['Email'],
          'Preferences': updatedUserData['Preferences'],
          'PhoneNumber': updatedUserData['PhoneNumber'],
          'Password': updatedUserData['Password'],
          'Image': updatedUserData['Image'],
          'Notifications': updatedUserData['Notifications'] ?? 0,
          'UpcomingEvents': updatedUserData['UpcomingEvents'] ?? 0,
        }, where: 'ID = ?', whereArgs: [updatedUserData['ID']]);
        print("User updated from Firebase to local");
      }
    });

    // onChildRemoved listener for the Users node
    usersRemovedSubscription=databaseRef.child('Users').onChildRemoved.listen((event) async {
      var removedUserData = event.snapshot.value;
      if (removedUserData is Map) {
        await db!.delete('Users', where: 'ID = ?', whereArgs: [removedUserData['ID']]);
        print("User removed from local cache: ID = ${removedUserData['ID']}");
      }
    });

    // onChildAdded listener for the Events node
    eventsAddedSubscription = databaseRef.child('Events').onChildAdded.listen((event) async{
      var eventsData = event.snapshot.value;
      if (eventsData is Map && (eventsData['UserID'] == userID || friendIds.contains(eventsData['UserID']))) {
        await db!.insert('Events', {
          'ID': eventsData['ID'],
          'Name': eventsData['Name'],
          'Date': eventsData['Date'],
          'Location': eventsData['Location'],
          'Description': eventsData['Description'],
          'Category': eventsData['Category'],
          'Status': eventsData['Status'],
          'UserID': eventsData['UserID']
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        print("Event Added from Firebase to local");
      }
    });

    // onChildUpdated listener for the Events node
    eventsChangedSubscription=databaseRef.child('Events').onChildChanged.listen((event) async {
      var updatedEventData = event.snapshot.value;
      if (updatedEventData is Map && (updatedEventData['UserID'] == userID || friendIds.contains(updatedEventData['UserID']))) {
        await db!.update('Events', {
          'ID': updatedEventData['ID'],
          'Name': updatedEventData['Name'],
          'Date': updatedEventData['Date'],
          'Location': updatedEventData['Location'],
          'Description': updatedEventData['Description'],
          'Category': updatedEventData['Category'],
          'Status': updatedEventData['Status'],
          'UserID': updatedEventData['UserID']
        }, where: 'ID = ?', whereArgs: [updatedEventData['ID']]);
        print("Event updated from Firebase to local");
      }
    });

    // onChildRemoved listener for the Events node
    eventsRemovedSubscription=databaseRef.child('Events').onChildRemoved.listen((event) async {
      var removedEventData = event.snapshot.value;
      if (removedEventData is Map) {
        await db!.delete('Events', where: 'ID = ?', whereArgs: [removedEventData['ID']]);
        print("Event removed from local cache: ID = ${removedEventData['ID']}");
      }
    });

    // onChildAdded listener for the Gifts node
    giftsAddedSubscription = databaseRef.child('Gifts').onChildAdded.listen((event)async {
      var giftsData = event.snapshot.value;
      if (giftsData is Map && (friendIds.contains(giftsData['UserID'])) && giftsData['IsPublished']==1) {
        await db!.insert('Gifts', {
          'ID': giftsData['ID'],
          'Name': giftsData['Name'],
          'Description': giftsData['Description'],
          'Category': giftsData['Category'],
          'Price': giftsData['Price'],
          'Image': giftsData['Image'],
          'Status': giftsData['Status'] ?? 0,
          'EventID': giftsData['EventID'],
          'PledgerID': giftsData['PledgerID'] ?? -1,
          'UserID': giftsData['UserID'],
          'IsPublished':giftsData['IsPublished']
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        print("Gift Added from Firebase to local");
      }
      else if(giftsData is Map && giftsData['UserID'] == userID){
        await db!.insert('Gifts', {
          'ID': giftsData['ID'],
          'Name': giftsData['Name'],
          'Description': giftsData['Description'],
          'Category': giftsData['Category'],
          'Price': giftsData['Price'],
          'Image': giftsData['Image'],
          'Status': giftsData['Status'] ?? 0,
          'EventID': giftsData['EventID'],
          'PledgerID': giftsData['PledgerID'] ?? -1,
          'UserID': giftsData['UserID'],
          'IsPublished':giftsData['IsPublished']
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        print("Gift Added from Firebase to local");
      }
    });

    // onChildUpdated listener for the Gifts node
    giftsChangedSubscription=databaseRef.child('Gifts').onChildChanged.listen((event) async {
      var updatedGiftData = event.snapshot.value;
      if (updatedGiftData is Map && (friendIds.contains(updatedGiftData['UserID'])) && updatedGiftData['IsPublished']==1) {
        await db!.update('Gifts', {
          'ID': updatedGiftData['ID'],
          'Name': updatedGiftData['Name'],
          'Description': updatedGiftData['Description'],
          'Category': updatedGiftData['Category'],
          'Price': updatedGiftData['Price'],
          'Image': updatedGiftData['Image'],
          'Status': updatedGiftData['Status'] ?? 0,
          'EventID': updatedGiftData['EventID'],
          'PledgerID': updatedGiftData['PledgerID'] ?? -1,
          'UserID': updatedGiftData['UserID'],
          'IsPublished':updatedGiftData['IsPublished']
        }, where: 'ID = ?', whereArgs: [updatedGiftData['ID']]);
        print("Gift updated from Firebase to local");
      }
      else if(updatedGiftData is Map && updatedGiftData['UserID'] == userID){
        await db!.update('Gifts', {
          'ID': updatedGiftData['ID'],
          'Name': updatedGiftData['Name'],
          'Description': updatedGiftData['Description'],
          'Category': updatedGiftData['Category'],
          'Price': updatedGiftData['Price'],
          'Image': updatedGiftData['Image'],
          'Status': updatedGiftData['Status'] ?? 0,
          'EventID': updatedGiftData['EventID'],
          'PledgerID': updatedGiftData['PledgerID'] ?? -1,
          'UserID': updatedGiftData['UserID'],
          'IsPublished':updatedGiftData['IsPublished']
        }, where: 'ID = ?', whereArgs: [updatedGiftData['ID']]);
        print("Gift updated from Firebase to local");
      }
    });

    // onChildRemoved listener for the Gifts node
    giftsRemovedSubscription=databaseRef.child('Gifts').onChildRemoved.listen((event) async {
      var removedGiftData = event.snapshot.value;
      if (removedGiftData is Map) {
        await db!.delete('Gifts', where: 'ID = ?', whereArgs: [removedGiftData['ID']]);
        print("Gift removed from local cache: ID = ${removedGiftData['ID']}");
      }
    });
    BarcodeGiftsSubscription=databaseRef.child('BarcodeGifts').onChildAdded.listen((event)async{
      var giftsData = event.snapshot.value;
      if (giftsData is Map) {
        await db!.insert('BarcodeGifts', {
        'ID': giftsData['ID'],
        'Barcode':giftsData['Barcode'],
        'Name': giftsData['Name'],
        'Description': giftsData['Description'],
        'Category': giftsData['Category'],
        'Price': giftsData['Price'],
        'Image': giftsData['Image'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        print("Barcode gift Added from firebase to local");
      }
    });
    return 2;
  }

// fetch information fo newly added friend
Future<void>  fetchAndSyncFriendData(int friendID, Database db, DatabaseReference databaseRef) async {
    // Fetch and sync the friend's user details
    final userSnapshot = await databaseRef.child('Users/$friendID').get();
    if (userSnapshot.value is Map) {
      var userData = userSnapshot.value as Map;
      await db.insert('Users', {
        'ID': userData['ID'],
        'Name': userData['Name'],
        'Email': userData['Email'],
        'Preferences': userData['Preferences'],
        'PhoneNumber': userData['PhoneNumber'],
        'Password': userData['Password'],
        'Image': userData['Image'],
        'Notifications': userData['Notifications'] ?? 0,
        'UpcomingEvents': userData['UpcomingEvents'] ?? 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      print("Friend user data synced: FriendID = $friendID");
    }

    // Fetch and sync the friend's events
    final eventsSnapshot = await databaseRef.child('Events').get();
    if (eventsSnapshot.value is Map) {
      final eventsMap = eventsSnapshot.value as Map;
      for (var entry in eventsMap.entries) {
        final event = entry.value;
        if (event is Map && event['UserID'] == friendID) {
          await db.insert('Events', {
            'ID': event['ID'],
            'Name': event['Name'],
            'Date': event['Date'],
            'Location': event['Location'],
            'Description': event['Description'],
            'Category': event['Category'],
            'Status': event['Status'],
            'UserID': event['UserID']
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          print("Friend event synced: EventID = ${event['ID']}");
        }
      }
    }

    // Fetch and sync the friend's gifts
    final giftsSnapshot = await databaseRef.child('Gifts').get();
    if (giftsSnapshot.value is Map) {
      final giftsMap = giftsSnapshot.value as Map;
      for (var entry in giftsMap.entries) {
        final gift = entry.value;
        if (gift is Map && gift['UserID'] == friendID && gift['IsPublished']==1) {
          await db.insert('Gifts', {
            'ID': gift['ID'],
            'Name': gift['Name'],
            'Description': gift['Description'],
            'Category': gift['Category'],
            'Price': gift['Price'],
            'Image': gift['Image'],
            'Status': gift['Status'] ?? 0,
            'EventID': gift['EventID'],
            'PledgerID': gift['PledgerID'] ?? -1,
            'UserID' : gift['UserID'],
            'IsPublished':gift['IsPublished']
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          print("Friend gift synced: GiftID = ${gift['ID']}");
        }
      }
    }

  }



// Function to cancel all listeners on sign-out
  cancelRealtimeListeners() async{
    await friendsSubscription?.cancel();
    await usersAddedSubscription?.cancel();
    await usersChangedSubscription?.cancel();
    await usersRemovedSubscription?.cancel();
    await eventsAddedSubscription?.cancel();
    await eventsChangedSubscription?.cancel();
    await eventsRemovedSubscription?.cancel();
    await giftsAddedSubscription?.cancel();
    await giftsChangedSubscription?.cancel();
    await giftsRemovedSubscription?.cancel();
    await BarcodeGiftsSubscription?.cancel();
    print("All Firebase listeners have been cancelled.");
  }


  void DeleteLocalDataOnSignOut()async{
    Database? db = await MyDataBase;
    await db!.execute("Delete from Users");
    print("Users table deleted successfully");

    await db!.execute("Delete from Friends");
    print("Friends table deleted successfully");

    await db!.execute("Delete from Gifts");
    print("Gifts table deleted successfully");

    await db!.execute("Delete from Events");
    print("Events table deleted successfully");
  }
// executed after modifying or adding new users
  Future<void> syncUsersTableToFirebase() async {
    Database? db = await MyDataBase;
    final firebaseRef = FirebaseDatabase.instance.ref();
    List<Map<String, dynamic>> users = await db!.query('Users');

    for (var user in users) {
      Friend friend = Friend.fromMap(user);
      String firebaseUid = friend.id.toString();

      DatabaseReference userRef = firebaseRef.child('Users').child(firebaseUid);
      DatabaseEvent event = await userRef.once();
      if (event.snapshot.exists) {
        await userRef.update(friend.toMap());
      } else {
        await userRef.set(friend.toMap());
      }
    }
  }
// executed after modifying or adding new events
  Future<void> syncEventsTableToFirebase() async {
    // Get all events from SQLite
    Database? db = await MyDataBase;
    final firebaseRef = FirebaseDatabase.instance.ref();
    List<Map<String, dynamic>> events = await db!.query('Events');

    for (var event in events) {
      Event currentEvent = Event.fromMap(event);
      DatabaseReference eventRef = firebaseRef.child('Events').child(currentEvent.id.toString());
      DatabaseEvent firebaseEvent = await eventRef.once();
      if (firebaseEvent.snapshot.exists) {
        await eventRef.update(currentEvent.toMap());
      } else {
        await eventRef.set(currentEvent.toMap());
      }
    }
  }
//executed after deleting an event
  Future<void> syncEventsDeletionToFirebase(int eventId) async{
    await FirebaseDatabase.instance.ref('Events/$eventId').remove();
  }
//executed after modifying or adding new gifts
  Future<void> syncGiftsTableToFirebase() async {
    Database? db = await MyDataBase;
    final firebaseRef = FirebaseDatabase.instance.ref();
    // Get all gifts from SQLite
    List<Map<String, dynamic>> gifts = await db!.query('Gifts');

    for (var gift in gifts) {
      Gift currentGift = Gift.fromMap(gift);
      DatabaseReference giftRef = firebaseRef.child('Gifts').child(currentGift.id.toString());
      DatabaseEvent firebaseGift = await giftRef.once();
      if (firebaseGift.snapshot.exists) {
        await giftRef.update(currentGift.toMap());
      } else {
        await giftRef.set(currentGift.toMap());
      }
    }
  }
  // executed after deleting a gift
  Future<void> syncGiftsDeletionToFirebase(int GiftID) async{
    await FirebaseDatabase.instance.ref('Gifts/$GiftID').remove();
  }
//executed after adding new friendship
  Future<void> syncFriendsTableToFirebase() async {
    Database? db = await MyDataBase;
    final firebaseRef = FirebaseDatabase.instance.ref();

    List<Map<String, dynamic>> friends = await db!.query('Friends');

    for (var friend in friends) {
      int userID = friend['UserID'];
      int friendID = friend['FriendID'];
      int ID = friend['ID'];

      Map<String, dynamic> friendMap = {
        'UserID': userID,
        'FriendID': friendID,
        'ID':ID
      };

      DatabaseReference friendRef = firebaseRef.child('Friends').child(ID.toString());

      DatabaseEvent firebaseFriend = await friendRef.once();
      if (firebaseFriend.snapshot.exists) {
        await friendRef.update(friendMap);
      } else {
        await friendRef.set(friendMap);
      }
    }
  }


}
