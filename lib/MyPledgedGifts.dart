import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Gift.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'PledgedGiftCard.dart';

class MyPledgedGifts extends StatefulWidget{
  List<Gift> pledgedgifts;
  MyPledgedGifts({required this.pledgedgifts});
  @override
  MyPledgedGiftsState createState() => MyPledgedGiftsState();
}
class MyPledgedGiftsState extends State<MyPledgedGifts>{


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
            ...widget.pledgedgifts.map((Gift) => Column(
              children: [
                PledgedGiftCard(
                  GName : Gift.name,
                  UName: Gift.Ownername!,
                  due: Gift.DueDate!.toIso8601String().split('T')[0],
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
