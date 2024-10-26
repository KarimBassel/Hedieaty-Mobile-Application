import 'dart:io';
import 'package:flutter/material.dart';
import 'Gift.dart';


class Event {
  int? id;
  String name;
  String category;
  String status;
  String? date;
  String? location;
  String? description;
  int? userId;

  Event({required this.name, required this.category, required this.status,this.date,this.location,this.description,this.id,this.userId});

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
}

