import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'PledgedGiftCard.dart';

class MyPledgedGifts extends StatefulWidget{

  @override
  MyPledgedGiftsState createState() => MyPledgedGiftsState();
}
class MyPledgedGiftsState extends State<MyPledgedGifts>{
  final List<Map<String, String>> Gifts = [
    {
      "GName": "PlayStation 5",
      "FName": "Lionel Messi",
      "DueDate": "5th of December"
    },
    {
      "GName": "MacBook Pro",
      "FName": "Elon Musk",
      "DueDate": "1st of November"
    },
    {
      "GName": "Samsung Galaxy S23",
      "FName": "Serena Williams",
      "DueDate": "15th of October"
    },
    {
      "GName": "AirPods Pro",
      "FName": "Bill Gates",
      "DueDate": "20th of September"
    },
    {
      "GName": "Tesla Model 3",
      "FName": "Jeff Bezos",
      "DueDate": "25th of December"
    },
    {
      "GName": "Apple Watch Series 9",
      "FName": "Oprah Winfrey",
      "DueDate": "30th of January"
    },
    {
      "GName": "Kindle Paperwhite",
      "FName": "J.K. Rowling",
      "DueDate": "7th of August"
    },
    {
      "GName": "GoPro HERO 11",
      "FName": "Dwayne Johnson",
      "DueDate": "12th of July"
    },
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("My Pledged Gifts")),
      ),
      body: ListView(
        children: [Column(
          children: [
            SizedBox(height: 15,),
            ...Gifts.map((Gift) => Column(
              children: [
                PledgedGiftCard(
                  GName : Gift["GName"]!,
                  UName: Gift["FName"]!,
                  due: Gift["DueDate"]!,
                ),
                SizedBox(height: 10,),
              ],
            )),
          ],
        ),
    ],
      )

    );
  }
}
