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
    // return Card(
    //   elevation: 4,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(15),
    //   ),
    //   child: Container(
    //     width: double.infinity,
    //     padding: const EdgeInsets.all(10.0),
    //     child: Row(
    //       children: [
    //         CircleAvatar(
    //           radius: 35,
    //           backgroundImage: NetworkImage(imageUrl),
    //         ),
    //         SizedBox(width: 10),
    //         Expanded(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: [
    //               Text(
    //                 name,
    //                 style: TextStyle(
    //                     fontSize: 20, fontWeight: FontWeight.bold),
    //               ),
    //               Text(
    //                 eventStatus,
    //                 style: TextStyle(
    //                     color: Colors.green, fontSize: 15),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return ListTile(
      leading: CircleAvatar( backgroundImage: NetworkImage(imageUrl),),
      title: Text(name),
      subtitle: Text(eventStatus),
    );
  }
}