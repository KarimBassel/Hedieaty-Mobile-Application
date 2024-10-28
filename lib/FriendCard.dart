import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Base Classes/Friend.dart';

class FriendsCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String eventStatus;

  const FriendsCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.eventStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar( backgroundImage: NetworkImage(imageUrl),),
      title: Text(name),
      subtitle: Text(eventStatus),
    );
  }
}