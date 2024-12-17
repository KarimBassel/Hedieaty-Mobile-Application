import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Database.dart';
import 'Gift.dart';


class Event {
  int? id;
  String name;
  String category;
  String status;
  DateTime? date;
  String? location;
  String? description;
  List<Gift>? giftlist;
  int? userId;

  Event({required this.name, required this.category, required this.status,this.date,this.location,this.description,this.id,this.userId});


  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['ID'],
      category: map["Category"],
      status: map['Status'],
      name: map['Name'],
      date: DateTime.parse(map['Date']),
      location: map['Location'],
      description: map['Description'],
      userId: map['UserID'],
    );
  }

  Map<String, dynamic> toMap() {
    String status = (date != null && date!.isAfter(DateTime.now())) ? "Upcoming" : "Completed";
    return {
      'ID': id,
      'Status': status,
      'Category': category,
      'Name': name,
      'Date': date?.toIso8601String().split('T')[0],
      'Location': location,
      'Description': description,
      'UserID': userId,
    };
  }

  static Future<void> insertEvent(Event event) async {
    final db = await Databaseclass();
    await db.insertData("INSERT INTO Events (ID,Name, Category, Status, Date, Location, Description, UserID) VALUES (${event.id},'${event.name}', '${event.category}', '${event.status}', '${event.date?.toIso8601String().split('T')[0]}', '${event.location}', '${event.description}', ${event.userId });");
    print("Event inserted successfully");
  }
  static Future<bool> updateEvent(Event event) async{
    try {
      final db = await Databaseclass();

      String query = '''UPDATE Events SET Name='${event.name}' , Category='${event
          .category}' ,Status='${event.status}' , Date='${event.date
          ?.toIso8601String().split('T')[0]}', Location='${event
          .location}', Description='${event.description}'  WHERE ID = ${event
          .id}''';

      int result = await db.updateData(query);

      if (result > 0) {
        print("Event updated successfully.");
        return true;
      } else {
        print("No rows were updated.");
        return false;
      }
    }catch(e){
      print("Error updating event: $e");
      return false;
    }

  }

  static Future<Event?> getEventById(int id) async {
    final db = await Databaseclass();

    try {
      String query = "SELECT * FROM Events WHERE ID = $id";
      List<Map<String, dynamic>> result = await db.readData(query);
      if (result.isNotEmpty) {
        Event event = Event.fromMap(result.first);
        List<Gift> giftList = await Gift.getGiftList(event.id!);
        event.giftlist=giftList;

        return event;
      } else {
        print("No event found with ID $id.");
        return null;
      }
    } catch (e) {
      print("Error fetching event by ID: $e");
      return null;
    }
  }

  static Future<bool?> deleteEvent(int EventID) async {

    try {
      final db = await Databaseclass();

      String query = "DELETE FROM Events WHERE ID = ${EventID}";

      int result = await db.deleteData(query);


      if (result > 0) {
        print("Event Deleted successfully.");
        return true;
      } else {
        print("No rows were updated.");
        return false;
      }
    }catch(e){
      print("Error fetching event by ID: $e");
      return false;
    }

  }






}

