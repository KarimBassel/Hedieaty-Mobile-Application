import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Models/Gift.dart';
import '../Views/GiftList.dart';
import '../Database.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:hedieatymobileapplication/Authentication.dart';

import '../Models/Event.dart';
import '../Models/Friend.dart';

class EventController{
  final Databaseclass db = Databaseclass();
  final databaseRef = FirebaseDatabase.instance.ref();
  final AuthService auth = AuthService();

 fetchEventsFromLocalDb(bool isOwner,int userid) async {
    await Future.delayed(const Duration(seconds: 1));
    if(isOwner)return await Friend.getUserObject(userid);
    else return await Friend.getUserObject(userid);
  }

  loadEvents(bool isOwner,int userid,int? friendid) async {
    if (isOwner) {
      return await Friend.getEvents(userid);
    } else {
      return await Friend.getEvents(friendid);
    }
  }

  Future<List<Event>> getEvents(bool isOwner,int userid,int? friendid) async {
    if (isOwner) {
      return await Friend.getEvents(userid);
    } else {
      return await Friend.getEvents(friendid);
    }
  }

  PickEventDate(Event? event,BuildContext context)async{
    DateTime? selectedDate = event?.date;
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    return pickedDate;
  }

  SaveEvent(String name,String category,String location,String description,DateTime? selectedDate,BuildContext context,
      Event? event,int userid)async{

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    Navigator.of(context).pop();
    final DateTime today = DateTime.now();
    final status = selectedDate!.isBefore(today)
        ? 'Completed'
        : 'Upcoming';

    if (event == null) {
      int generatedid = await generateUniqueGiftId();
      // Add new event
      await Event.insertEvent(Event(
        id: generatedid,
        name: name,
        category: category,
        status: status,
        date: selectedDate,
        location: location,
        description: description,
        userId: userid,
      ));
      showCustomSnackBar(context, "Event Added Successfully", backgroundColor: Colors.green);
    } else {
      // Update existing event
      event.name = name;
      event.category = category;
      event.status = status;
      event.date = selectedDate;
      event.location = location;
      event.description = description;
      bool? updateStatus = await Event.updateEvent(event);
      showCustomSnackBar(context, "Event Updated Successfully", backgroundColor: Colors.green);
    }
    await db.syncEventsTableToFirebase();
    //Navigator.of(context).pop();
    //loadEvents();
  }

  Future<int> generateUniqueGiftId() async {
    DatabaseReference giftsRef = FirebaseDatabase.instance.ref("Events");
    DataSnapshot snapshot = await giftsRef.get();
    List<int> existingGiftIds = [];

    if (snapshot.exists) {
      if (snapshot.value is Map) {
        Map<String, dynamic> giftsMap = Map<String, dynamic>.from(snapshot.value as Map);
        existingGiftIds = giftsMap.keys.map((key) => int.tryParse(key) ?? 0).toList();
      } else if (snapshot.value is List) {
        List<dynamic> giftsList = snapshot.value as List;
        for (int i = 0; i < giftsList.length; i++) {
          if (giftsList[i] != null) {
            existingGiftIds.add(i);
          }
        }
      } else {
        print("Unexpected Firebase data format: ${snapshot.value.runtimeType}");
      }
    } else {
      print("Firebase snapshot is empty or does not exist.");
    }

    int index = 1;
    while (existingGiftIds.contains(index)) {
      print("Checking index: $index");
      index++;
    }

    return index;
  }


deleteEvent(Event event) async {
    bool? success = await Event.deleteEvent(event.id!);
    await DeleteEventGifts(event.id!);
    return success;
  }
  DeleteEventGifts(int eventid)async{
   List<Gift> gifts = await Gift.getGiftList(eventid);
   await Gift.deleteGiftsByEventId(eventid);
   for(var gift in gifts){
     await db.syncGiftsDeletionToFirebase(gift.id!);
   }

  }
  GoToGiftList(int eventid, bool isOwner, Friend User, BuildContext context) async {
    Event? e = await Event.getEventById(eventid);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => GiftListPage(
          event: e!,
          isOwner: isOwner,
          User: User,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  SyncDeletiontoFirebase(int eventid)async{
  await db.syncEventsDeletionToFirebase(eventid);
}
SyncEventstoFirebase()async{
    await db.syncEventsTableToFirebase();
}

  void showCustomSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.red}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}