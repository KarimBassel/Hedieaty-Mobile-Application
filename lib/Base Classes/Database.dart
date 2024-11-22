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
  Email TEXT UNIQUE NOT NULL,
  Preferences TEXT,
  PhoneNumber TEXT NOT NULL,
  Password TEXT NOT NULL,
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
  FOREIGN KEY (EventID) REFERENCES Events(ID)
);
''');

db.execute('''
CREATE TABLE Friends (
  UserID INTEGER NOT NULL,
  FriendID INTEGER NOT NULL,
  PRIMARY KEY (UserID, FriendID),
  FOREIGN KEY (UserID) REFERENCES Users(ID),
  FOREIGN KEY (FriendID) REFERENCES Users(ID)
);
''');



      db.execute('''INSERT INTO Events (Name, Date, Location, Description, Category, Status, UserID) VALUES
  ('Birthday Party', '2024-12-15', 'Johns House', 'A fun celebration with friends and family', 'Birthday','Upcoming', 1),
  ('Wedding Anniversary', '2024-11-30', 'Janes House', 'Celebrating our special day', 'Anniversary', 'Upcoming',1),
  ('Tech Conference', '2024-10-25', 'Convention Center', 'A conference on the latest tech trends', 'Completed', 'Upcoming',1),
  ('Art Exhibition', '2024-09-20', 'Art Gallery', 'An exhibition showcasing local artists', 'Completed', 'Upcoming',1);
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
}
