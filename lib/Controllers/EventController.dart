import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Views/GiftList.dart';
import '../Models/Database.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:hedieatymobileapplication/Models/Authentication.dart';

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
  // void _loadEvents() async {
  //   List<Event> loadedEvents = await getEvents();
  //   setState(() {
  //     events = loadedEvents;
  //   });
  // }

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

    final DateTime today = DateTime.now();
    final status = selectedDate!.isBefore(today)
        ? 'Completed'
        : 'Upcoming';

    if (event == null) {
      // Add new event
      await Event.insertEvent(Event(
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
    Navigator.of(context).pop();
    //loadEvents();
  }


deleteEvent(Event event) async {
    bool? success = await Event.deleteEvent(event.id!);
    return success;
  }

  GoToGiftList(int eventid,bool isOwner,Friend User,BuildContext context)async{
    Event? e = await Event.getEventById(eventid);;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftListPage(
          event: e!,
          isOwner: isOwner,
          User: User,
        ),
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