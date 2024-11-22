import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Database.dart';
import 'Gift.dart';


class Event {
  int? id;
  String name;
  String category;
  String status;
  DateTime? date;
  String? location;
  String? description;
  int? userId;

  Event({required this.name, required this.category, required this.status,this.date,this.location,this.description,this.id,this.userId});


  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['ID'],
      category: map["Category"],
      status: "Upcoming",
      name: map['Name'],
      date: DateTime.parse(map['Date']),
      location: map['Location'],
      description: map['Description'],
      userId: map['UserID'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'userId': userId,
    };
  }

  static Future<void> insertEvent(Event event) async {
    final db = await Databaseclass();
    await db.insertData("INSERT INTO Events (Name, Category, Status, Date, Location, Description, UserID) VALUES ('${event.name}', '${event.category}', '${event.status}', '${event.date?.toIso8601String().split('T')[0]}', '${event.location}', '${event.description}', ${event.userId });");
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
      // Query the Events table for the row with the given ID
      String query = "SELECT * FROM Events WHERE ID = $id";

      // Execute the query and get the result
      List<Map<String, dynamic>> result = await db.readData(query);

      // If the result is not empty, map the first row to an Event object
      if (result.isNotEmpty) {
        return Event.fromMap(result.first);
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

