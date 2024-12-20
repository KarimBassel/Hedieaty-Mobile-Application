import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Controllers/GiftController.dart';
import 'package:hedieatymobileapplication/Models/Gift.dart';
import 'PledgedGiftCard.dart';

class MyPledgedGifts extends StatefulWidget {
  List<Gift> pledgedgifts;

  MyPledgedGifts({required this.pledgedgifts});

  @override
  MyPledgedGiftsState createState() => MyPledgedGiftsState();
}

class MyPledgedGiftsState extends State<MyPledgedGifts> {
  final GiftController controller = GiftController();
  void _deleteGift(Gift gift) {
    if(mounted)
    setState(() {
      widget.pledgedgifts.remove(gift);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("My Pledged Gifts")),
      ),
      body: widget.pledgedgifts.isEmpty
          ? Center(
        child: Text(
          "No pledged gifts available.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView(
        children: [
          Column(
            children: [
              SizedBox(height: 15),
              ...widget.pledgedgifts.map((gift) {
                bool isCompleted = gift.DueDate != null && gift.DueDate!.isBefore(DateTime.now());
                return Column(
                  children: [
                    Stack(
                      children: [
                        PledgedGiftCard(
                          GName: gift.name,
                          UName: gift.Ownername!,
                          due: !isCompleted?gift.DueDate!.toIso8601String().split('T')[0]:"",
                        ),
                        if (isCompleted)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Row(
                              children: [
                                Chip(
                                  label: Text(
                                    "Completed",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                  ),
                                  onPressed: ()async{
                                    _deleteGift(gift);
                                    await controller.RemoveFromMyPledgedGifts(gift);
                                    await controller.syncGiftsTableToFirebase();
                                },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
