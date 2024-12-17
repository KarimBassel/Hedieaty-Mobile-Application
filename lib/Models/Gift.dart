import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Database.dart';

class Gift {
  int? id;
  int? eventId;
  String name;
  String category;
  String status;
  String description;
  int price;
  String? image;
  int? PledgerID;
  String? Ownername;
  DateTime? DueDate;
  int UserID;
  int IsPublished;

  Gift({
    required this.name,
    required this.category,
    required this.status,
    required this.description,
    required this.price,
    this.image,
    this.eventId,
    this.id,
    this.PledgerID,
    required this.UserID,
    required this.IsPublished
  });

  factory Gift.fromMap(Map<String, dynamic> map) {
    //print(map);

    return Gift(
      id: map['ID'],
      name: map['Name'],
      description: map['Description'],
      price: map['Price'],
      category: map["Category"],
      status: (map["Status"]==0)?"Available":"Pledged",
      eventId: map['EventID'],
      image: map['Image'],
      PledgerID: map['PledgerID'],
      UserID: map['UserID'],
      IsPublished: map["IsPublished"]
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'Name': name,
      'Description': description,
      'Category': category,
      'Price': price,
      'Status': (status=="Available")?0:1,
      'EventID': eventId,
      'Image' : image,
      'PledgerID':PledgerID??-1,
      'UserID':UserID,
      'IsPublished' : IsPublished
    };
  }
 static Future<List<Gift>> getGiftList(int eventId) async {
    final db = await Databaseclass();
    String query = "SELECT * FROM Gifts WHERE EventID=${eventId}";
    List<Map<String, dynamic>> result = await db.readData(query);

    List<Gift> giftlist = [];
    if (result.isEmpty) return giftlist;

    for (var eventData in result) {
      Gift gift = Gift.fromMap(eventData);
      giftlist.add(gift);
    }
    return giftlist;
  }
  static Future<void> deleteGiftsByEventId(int eventId) async {
    final db = await Databaseclass();

    // Define the query to delete all gifts with the given EventID
    String query = "DELETE FROM Gifts WHERE EventID=${eventId}";

    // Execute the query
    await db.deleteData(query);
  }
  static Future<bool> addGift(Gift gift) async {
    final db = await Databaseclass();

    try {
      int status = (gift.status=="Available")?0:1;
      String query = """
      INSERT INTO Gifts (ID ,Name, Description, Category, Price, Image, Status, EventID,UserID)
      VALUES (${gift.id},'${gift.name}', '${gift.description}', '${gift.category}', ${gift.price}, '${gift.image}', ${status}, ${gift.eventId},${gift.UserID})
    """;


      int result = await db.insertData(query);

      if (result > 0) {
        print("Gift added successfully!");
        return true;
      } else {
        print("Failed to add gift.");
        return false;
      }
    } catch (e) {
      print("Error adding gift: $e");
      return false;
    }
  }

  static Future<bool> updateGift(Gift gift)async{
    try{
      final db = await Databaseclass();
      int status = (gift.status=="Available")?0:1;

      String query = '''
      UPDATE Gifts SET Name='${gift.name}',Description='${gift.description}',
      Category='${gift.category}',Price=${gift.price},Image='${gift.image}', PledgerID=${gift.PledgerID},Status=${status},IsPublished=${gift.IsPublished}
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
  static Future<bool> DeleteGift(int giftid)async{
    try {
      final db = await Databaseclass();

      String query = '''
      DELETE FROM GIFTS WHERE ID=${giftid}
      ''';

      int result = await db.deleteData(query);
      if (result > 0) {
        print("Gift Deleted successfully!");
        return true;
      } else {
        print("Failed to Delete gift.");
        return false;
      }
    }catch(e){
      print("Error deleting gift: $e");
      return false;
    }



  }

  static Future<Gift?> getGiftById(int id) async {
    final db = await Databaseclass();

    try {
      String query = "SELECT * FROM Gifts WHERE ID = $id";

      List<Map<String, dynamic>> result = await db.readData(query);

      if (result.isNotEmpty) {
        Gift gift = Gift.fromMap(result.first);
        return gift;
      } else {
        print("No gift found with ID $id.");
        return null;
      }
    } catch (e) {
      print("Error fetching gift by ID: $e");
      return null;
    }
  }
  static Future<Gift> CreateGiftByBarcode(String Barcode,int eventid,int userid)async{
    final db = await Databaseclass();

    String query = "SELECT * FROM BarcodeGifts WHERE Barcode = ${Barcode}";
    List<Map<String, dynamic>> result = await db.readData(query);


    Gift gift = Gift(name: result.first['Name'], category: result.first['Category'], status: "Available", description: result.first['Description'], price: result.first['Price'],eventId: eventid,PledgerID: -1,image: result.first['Image'],UserID: userid,IsPublished: 0);
    return gift;
  }
static Future<bool> CheckBarcode(String Barcode)async{
  final db = await Databaseclass();
  String query = "SELECT * FROM BarcodeGifts WHERE Barcode = ${Barcode}";
  List<Map<String, dynamic>> result = await db.readData(query);
  if (result.isNotEmpty) return true;
  return false;
}


}