import 'dart:io';
import 'package:flutter/material.dart';

class Gift {
  int? id;
  int? eventId;
  String name;
  String category;
  String status;
  String description;
  double price;
  File? image;

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
}