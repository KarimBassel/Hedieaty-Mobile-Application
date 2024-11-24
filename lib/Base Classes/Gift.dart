import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Database.dart';

class Gift {
  int? id;
  int? eventId;
  String name;
  String category;
  String status;
  String description;
  int price;
  String? image;

  Gift({
    required this.name,
    required this.category,
    required this.status,
    required this.description,
    required this.price,
    this.image,
    this.eventId,
    this.id
  });

  factory Gift.fromMap(Map<String, dynamic> map) {
    print(map);

    return Gift(
      id: map['ID'],
      name: map['Name'],
      description: map['Description'],
      price: map['Price'],
      category: map["Category"],
      status: (map["Status"]==0)?"Available":"Pledged",
      eventId: map['EventID'],
      image: map['Image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId,
      'image' : image,
    };
  }
 static Future<List<Gift>> getGiftList(int eventId) async {
    final db = await Databaseclass();
    String query = "SELECT * FROM Gifts WHERE EventID=${eventId}";
    List<Map<String, dynamic>> result = await db.readData(query);

    List<Gift> giftlist = [];
    if (result.isEmpty) return giftlist;

    // Step 3: Convert the events data to Event objects
    for (var eventData in result) {
      Gift gift = Gift.fromMap(eventData);
      giftlist.add(gift);
    }
    return giftlist;
  }

  static Future<bool> addGift(Gift gift) async {
    final db = await Databaseclass();

    try {
      // Prepare the SQL query to insert a new gift into the Gifts table
      int status = (gift.status=="Available")?0:1;
      String query = """
      INSERT INTO Gifts (Name, Description, Category, Price, Image, Status, EventID)
      VALUES ('${gift.name}', '${gift.description}', '${gift.category}', ${gift.price}, '${gift.image}', ${status}, ${gift.eventId})
    """;

      // Execute the query using insertData (assuming insertData method exists in Databaseclass)
      int result = await db.insertData(query);  // Returns number of affected rows

      if (result > 0) {
        print("Gift added successfully!");
        return true; // Return true if insertion was successful
      } else {
        print("Failed to add gift.");
        return false;
      }
    } catch (e) {
      print("Error adding gift: $e");
      return false; // Return false if there was an error
    }
  }

  static Future<bool> updateGift(Gift gift)async{
    try{
      final db = await Databaseclass();

      String query = '''
      UPDATE Gifts SET Name='${gift.name}',Description='${gift.description}',
      Category='${gift.category}',Price=${gift.price},Image='${gift.image}'
       WHERE EventID=${gift.eventId} and ID=${gift.id}
      ''';

      int result = await db.updateData(query);

      if (result > 0) {
        print("Gift updated successfully.");
        return true;
      } else {
        print("No rows were updated.");
        return false;
      }

    }catch(e){
      print("Error updating gift: $e");
      return false;
    }
  }


}