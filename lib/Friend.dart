import 'dart:io';
import 'package:flutter/material.dart';

class Friend {
  String name;
  String? email;
  String? preferences;
  String upev;
  String? image;

  Friend({
    required this.name,
    this.email,
    this.preferences,
    required this.upev,
    this.image,
  });
}