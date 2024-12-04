import 'package:firebase_database/firebase_database.dart';
import 'package:hedieatymobileapplication/Models/Event.dart';
import 'package:hedieatymobileapplication/Models/Friend.dart';
import 'package:hedieatymobileapplication/Models/Gift.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Databaseclass {
  static Database? _MyDataBase;

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

//no longer used
  Future<void> syncFromFirebase() async {
    Database? db = await MyDataBase;
    final databaseRef = FirebaseDatabase.instance.ref();

    try {
      await db!.delete('Users');
      await db.delete('Events');
      await db.delete('Gifts');
      await db.delete('Friends');
      print('All records deleted successfully from SQLite tables.');

      // Fetch Users from Firebase
      DatabaseEvent usersEvent = await databaseRef.child('Users').once();
      if (usersEvent.snapshot.exists) {
        Map<dynamic, dynamic> usersMap = usersEvent.snapshot.value as Map<dynamic, dynamic>;
        usersMap.forEach((key, user) async {
          if (user != null) {
            await db.insert('Users', {
              'ID': user['ID'],
              'Name': user['Name'],
              'Email': user['Email'],
              'Preferences': user['Preferences'],
              'PhoneNumber': user['PhoneNumber'],
              'Password': user['Password'],
              'Image': user['Image'],
              'Notifications': user['Notifications'] ?? 0,
              'UpcomingEvents': user['UpcomingEvents'] ?? 0,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        });
        print('Users synchronized successfully from Firebase to SQLite');
      }

      // Fetch Events from Firebase
      DatabaseEvent eventsEvent = await databaseRef.child('Events').once();
      if (eventsEvent.snapshot.exists) {
        var eventsData = eventsEvent.snapshot.value;
        if (eventsData is Map) {
          eventsData.forEach((key, value) {
            var event = value as Map<dynamic, dynamic>;
            db.insert('Events', {
              'ID': event['ID'],
              'Name': event['Name'],
              'Date': event['Date'],
              'Location': event['Location'],
              'Description': event['Description'],
              'Category': event['Category'],
              'Status': event['Status'],
              'UserID': event['UserID'],
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          });
        } else if (eventsData is List) {
          for (var event in eventsData) {
            if (event != null) {
              db.insert('Events', {
                'ID': event['ID'],
                'Name': event['Name'],
                'Date': event['Date'],
                'Location': event['Location'],
                'Description': event['Description'],
                'Category': event['Category'],
                'Status': event['Status'],
                'UserID': event['UserID'],
              }, conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        }
      }
      print('Events synchronized successfully from Firebase to SQLite');

      // Fetch Gifts from Firebase
      DatabaseEvent giftsEvent = await databaseRef.child('Gifts').once();
      if (giftsEvent.snapshot.exists) {
        var giftsData = giftsEvent.snapshot.value;
        if (giftsData is Map) {
          giftsData.forEach((key, value) {
            var gift = value as Map<dynamic, dynamic>;
            db.insert('Gifts', {
              'ID': gift['ID'],
              'Name': gift['Name'],
              'Description': gift['Description'],
              'Category': gift['Category'],
              'Price': gift['Price'],
              'Image': gift['Image'],
              'Status': gift['Status'] ?? 0,
              'EventID': gift['EventID'],
              'PledgerID': gift['PledgerID'] ?? -1,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          });
        } else if (giftsData is List) {
          for (var gift in giftsData) {
            if (gift != null) {
              db.insert('Gifts', {
                'ID': gift['ID'],
                'Name': gift['Name'],
                'Description': gift['Description'],
                'Category': gift['Category'],
                'Price': gift['Price'],
                'Image': gift['Image'],
                'Status': gift['Status'] ?? 0,
                'EventID': gift['EventID'],
                'PledgerID': gift['PledgerID'] ?? -1,
              }, conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        }
      }
      print('Gifts synchronized successfully from Firebase to SQLite');

      // Fetch Friends from Firebase
      DatabaseEvent friendsEvent = await databaseRef.child('Friends').once();
      if (friendsEvent.snapshot.exists) {
        var friendsData = friendsEvent.snapshot.value;
        if (friendsData is Map) {
          friendsData.forEach((key, value) {
            var friend = value as Map<dynamic, dynamic>;
            db.insert('Friends', {
              'UserID': friend['UserID'],
              'FriendID': friend['FriendID'],
              'ID' : friend['ID']
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          });
        } else if (friendsData is List) {
          for (var friend in friendsData) {
            if (friend != null) {
              db.insert('Friends', {
                'UserID': friend['UserID'],
                'FriendID': friend['FriendID'],
                'ID' : friend['ID']
              }, conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        }
      }

      print('Friends synchronized successfully from Firebase to SQLite');
    } catch (e) {
      print('Error syncing from Firebase: $e');
    }
  }
//no longer used
Future<void> syncUsersFromFirebase()async{
  Database? db = await MyDataBase;
  final databaseRef = FirebaseDatabase.instance.ref();
    try{

      await db!.delete('Users');
      print('Users table deleted successfully from SQLite tables.');

      DatabaseEvent usersEvent = await databaseRef.child('Users').once();
      if (usersEvent.snapshot.exists) {
        Map<dynamic, dynamic> usersMap = usersEvent.snapshot.value as Map<dynamic, dynamic>;
        usersMap.forEach((key, user) async {
          if (user != null) {
            await db.insert('Users', {
              'ID': user['ID'],
              'Name': user['Name'],
              'Email': user['Email'],
              'Preferences': user['Preferences'],
              'PhoneNumber': user['PhoneNumber'],
              'Password': user['Password'],
              'Image': user['Image'],
              'Notifications': user['Notifications'] ?? 0,
              'UpcomingEvents': user['UpcomingEvents'] ?? 0,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        });
        print('Users synchronized successfully from Firebase to SQLite');
      }
    }catch (e) {
      print('Error syncing from Firebase: $e');
    }

}
//no longer used
  Future<void> syncEventsFromFirebase()async{
    Database? db = await MyDataBase;
    final databaseRef = FirebaseDatabase.instance.ref();
    try{

      await db!.delete('Events');
      print('Events table deleted successfully from SQLite tables.');

      // Fetch Events from Firebase
      DatabaseEvent eventsEvent = await databaseRef.child('Events').once();
      if (eventsEvent.snapshot.exists) {
        var eventsData = eventsEvent.snapshot.value;
        if (eventsData is Map) {
          eventsData.forEach((key, value) {
            var event = value as Map<dynamic, dynamic>;
            db.insert('Events', {
              'ID': event['ID'],
              'Name': event['Name'],
              'Date': event['Date'],
              'Location': event['Location'],
              'Description': event['Description'],
              'Category': event['Category'],
              'Status': event['Status'],
              'UserID': event['UserID'],
              'IsNew' : 1,
              'IsUpdated':0,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          });
        } else if (eventsData is List) {
          for (var event in eventsData) {
            if (event != null) {
              db.insert('Events', {
                'ID': event['ID'],
                'Name': event['Name'],
                'Date': event['Date'],
                'Location': event['Location'],
                'Description': event['Description'],
                'Category': event['Category'],
                'Status': event['Status'],
                'UserID': event['UserID'],
              }, conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        }
      }
      print('Events synchronized successfully from Firebase to SQLite');

    }catch (e) {
      print('Error syncing from Firebase: $e');
    }

  }
//no longer used
  Future<void> syncGiftsFromFirebase()async{
    Database? db = await MyDataBase;
    final databaseRef = FirebaseDatabase.instance.ref();
    try{

      await db!.delete('Gifts');
      print('Gifts table deleted successfully from SQLite tables.');

      // Fetch Gifts from Firebase
      DatabaseEvent giftsEvent = await databaseRef.child('Gifts').once();
      if (giftsEvent.snapshot.exists) {
        var giftsData = giftsEvent.snapshot.value;
        if (giftsData is Map) {
          giftsData.forEach((key, value) {
            var gift = value as Map<dynamic, dynamic>;
            db.insert('Gifts', {
              'ID': gift['ID'],
              'Name': gift['Name'],
              'Description': gift['Description'],
              'Category': gift['Category'],
              'Price': gift['Price'],
              'Image': gift['Image'],
              'Status': gift['Status'] ?? 0,
              'EventID': gift['EventID'],
              'PledgerID': gift['PledgerID'] ?? -1,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          });
        } else if (giftsData is List) {
          for (var gift in giftsData) {
            if (gift != null) {
              db.insert('Gifts', {
                'ID': gift['ID'],
                'Name': gift['Name'],
                'Description': gift['Description'],
                'Category': gift['Category'],
                'Price': gift['Price'],
                'Image': gift['Image'],
                'Status': gift['Status'] ?? 0,
                'EventID': gift['EventID'],
                'PledgerID': gift['PledgerID'] ?? -1,
              }, conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        }
      }
      print('Gifts synchronized successfully from Firebase to SQLite');


    }catch (e) {
      print('Error syncing from Firebase: $e');
    }

  }
//no longer used
  Future<void> syncFriendsFromFirebase()async{
    Database? db = await MyDataBase;
    final databaseRef = FirebaseDatabase.instance.ref();
    try{

      await db!.delete('Friends');
      print('Friends table deleted successfully from SQLite tables.');

      // Fetch Friends from Firebase
      DatabaseEvent friendsEvent = await databaseRef.child('Friends').once();
      if (friendsEvent.snapshot.exists) {
        var friendsData = friendsEvent.snapshot.value;
        if (friendsData is Map) {
          friendsData.forEach((key, value) {
            var friend = value as Map<dynamic, dynamic>;
            db.insert('Friends', {
              'UserID': friend['UserID'],
              'FriendID': friend['FriendID'],
              'ID' : friend['ID']
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          });
        } else if (friendsData is List) {
          for (var friend in friendsData) {
            if (friend != null) {
              db.insert('Friends', {
                'UserID': friend['UserID'],
                'FriendID': friend['FriendID'],
                'ID' : friend['ID']
              }, conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        }
      }

      print('Friends synchronized successfully from Firebase to SQLite');


    }catch (e) {
      print('Error syncing from Firebase: $e');
    }

  }



  void setupRealtimeListeners()async {
    Database? db = await MyDataBase;
    final databaseRef = FirebaseDatabase.instance.ref();

    // Listen for changes in Users
    databaseRef.child('Users').onChildAdded.listen((event) {
      //syncUsersFromFirebase(); // Sync your database
      var usersMap = event.snapshot.value;
      if(usersMap is Map) {
             db!.insert('Users', {
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
          print("User Updated from firebase and local");
      }
    });
    databaseRef.child('Users').onChildChanged.listen((event) {
      //syncUsersFromFirebase(); // Sync your database
      var usersMap = event.snapshot.value;
      if(usersMap is Map) {
             db!.insert('Users', {
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
        print("User Updated from firebase and local");
      }
    });
    databaseRef.child('Users').onChildRemoved.listen((event) {
      //syncUsersFromFirebase(); // Sync your database
      var userdata = event.snapshot.value;
      if(userdata is Map && userdata.containsKey('ID')){
        int userid = userdata['ID'];
        db!.delete(
          'Users',
          where: 'ID = ?',
          whereArgs: [userid],
        );
        print("User Deleted from firebase and local");
      }
    });

    // Listen for changes in Events
    databaseRef.child('Events').onChildAdded.listen((event) {
      var eventsData = event.snapshot.value;
       if (eventsData is Map) {
           db!.insert('Events', {
             'ID': eventsData['ID'],
             'Name': eventsData['Name'],
             'Date': eventsData['Date'],
             'Location': eventsData['Location'],
             'Description': eventsData['Description'],
             'Category': eventsData['Category'],
             'Status': eventsData['Status'],
             'UserID': eventsData['UserID']
           }, conflictAlgorithm: ConflictAlgorithm.replace);

       }
       print("New Event Added from firebase to local");

    });
    databaseRef.child('Events').onChildChanged.listen((event) {
      var eventsData = event.snapshot.value;
      if (eventsData is Map) {
        db!.insert('Events', {
          'ID': eventsData['ID'],
          'Name': eventsData['Name'],
          'Date': eventsData['Date'],
          'Location': eventsData['Location'],
          'Description': eventsData['Description'],
          'Category': eventsData['Category'],
          'Status': eventsData['Status'],
          'UserID': eventsData['UserID']
        }, conflictAlgorithm: ConflictAlgorithm.replace);

      }
      print("Event Updated from firebase to local");

    });
    databaseRef.child('Events').onChildRemoved.listen((event) {
      var eventsData = event.snapshot.value;
      print(eventsData);
      print(eventsData.runtimeType);
      if (eventsData is Map && eventsData.containsKey('ID')) {
        int eventId = eventsData['ID'];
        db!.delete(
          'Events',
          where: 'ID = ?',
          whereArgs: [eventId],
        );
        print("Event Deleted from firebase and local");
      }
    });

    // Listen for changes in Friends
    databaseRef.child('Friends').onChildAdded.listen((event) {
      //syncFriendsFromFirebase();
      var friendsData = event.snapshot.value;
      if (friendsData is Map) {
          db!.insert('Friends', {
            'UserID': friendsData['UserID'],
            'FriendID': friendsData['FriendID'],
            'ID' : friendsData['ID']
          }, conflictAlgorithm: ConflictAlgorithm.replace);

          print("New Friendship synced from firebase to local");
      }

    });
    databaseRef.child('Friends').onChildChanged.listen((event) {
      //syncFriendsFromFirebase();
      var friendsData = event.snapshot.value;
      if (friendsData is Map) {
        db!.insert('Friends', {
          'UserID': friendsData['UserID'],
          'FriendID': friendsData['FriendID'],
          'ID' : friendsData['ID']
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        print("Friendship Updated from firebase to local");
      }
    });
    databaseRef.child('Friends').onChildRemoved.listen((event) {
      //syncFriendsFromFirebase();
      var friendsdata = event.snapshot.value;
      if(friendsdata is Map && friendsdata.containsKey('ID')){
        int friendshipid = friendsdata['ID'];
        db!.delete(
          'Friends',
          where: 'ID = ?',
          whereArgs: [friendshipid],
        );
        print("Friendship Deleted from firebase to local");
      }
    });

    // Listen for changes in Gifts
    databaseRef.child('Gifts').onChildAdded.listen((event) {
      //syncGiftsFromFirebase();
      var giftsData = event.snapshot.value;
      if (giftsData is Map) {
          db!.insert('Gifts', {
            'ID': giftsData['ID'],
            'Name': giftsData['Name'],
            'Description': giftsData['Description'],
            'Category': giftsData['Category'],
            'Price': giftsData['Price'],
            'Image': giftsData['Image'],
            'Status': giftsData['Status'] ?? 0,
            'EventID': giftsData['EventID'],
            'PledgerID': giftsData['PledgerID'] ?? -1,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          print("Gift Added from firebase to local");
      }
    });
    databaseRef.child('Gifts').onChildChanged.listen((event) {
      //syncGiftsFromFirebase();
      var giftsData = event.snapshot.value;
      if (giftsData is Map) {
        db!.insert('Gifts', {
          'ID': giftsData['ID'],
          'Name': giftsData['Name'],
          'Description': giftsData['Description'],
          'Category': giftsData['Category'],
          'Price': giftsData['Price'],
          'Image': giftsData['Image'],
          'Status': giftsData['Status'] ?? 0,
          'EventID': giftsData['EventID'],
          'PledgerID': giftsData['PledgerID'] ?? -1,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        print("Gift Updated from firebase to local");
      }
    });
    databaseRef.child('Gifts').onChildRemoved.listen((event) {
      //syncGiftsFromFirebase();
      var giftdata = event.snapshot.value;
      if(giftdata is Map && giftdata.containsKey('ID')){
        int giftid = giftdata['ID'];
        db!.delete(
          'Gifts',
          where: 'ID = ?',
          whereArgs: [giftid],
        );
        print("Gift Deleted from firebase to local");
      }
    });


    databaseRef.child('BarcodeGifts').onChildAdded.listen((event){
      var giftsData = event.snapshot.value;
      if (giftsData is Map) {
        db!.insert('BarcodeGifts', {
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
    databaseRef.child('BarcodeGifts').onChildAdded.listen((event){
      var giftsData = event.snapshot.value;
      if (giftsData is Map) {
        db!.insert('BarcodeGifts', {
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
    });databaseRef.child('BarcodeGifts').onChildChanged.listen((event){
      var giftsData = event.snapshot.value;
      if (giftsData is Map) {
        db!.insert('BarcodeGifts', {
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
  }



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

  Future<void> syncEventsDeletionToFirebase(int eventId) async{
    await FirebaseDatabase.instance.ref('Events/$eventId').remove();
  }

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
  Future<void> syncGiftsDeletionToFirebase(int GiftID) async{
    await FirebaseDatabase.instance.ref('Gifts/$GiftID').remove();
  }

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
