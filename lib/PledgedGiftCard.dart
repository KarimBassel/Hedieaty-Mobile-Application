import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class PledgedGiftCard extends StatelessWidget {
  final String GName;
  final String UName;
  final String due;

  const PledgedGiftCard({
    Key? key,
    required this.GName,
    required this.UName,
    required this.due,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(

        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(GName, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                  Text(UName,style:TextStyle(fontSize: 15),)
                ],
              ),
            ),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
                children:[ Text(due,style: TextStyle(fontSize: 17,color: Colors.green),)]))
          ],
        ),
      ),
    );
  }
}