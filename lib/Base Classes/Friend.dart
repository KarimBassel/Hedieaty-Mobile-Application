import 'dart:io';
import 'package:flutter/material.dart';

class Friend {
  int? id;
  String name;
  String? email;
  String? preferences;
  String upev;
  String? image;

  Friend({
    this.id,
    required this.name,
    this.email,
    this.preferences,
    required this.upev,
    this.image,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences,
      'upev' : upev,
      'image' : image
    };
  }
}