import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Controllers/EventController.dart';
import 'package:hedieatymobileapplication/Models/Database.dart';
import 'package:hedieatymobileapplication/Models/Friend.dart';
import 'package:hedieatymobileapplication/Views/GiftList.dart';
import '../Models/Event.dart';

class EventListPage extends StatefulWidget {
  final bool isOwner;
  Friend User;
  Friend? friend;
  EventListPage({required this.isOwner, required this.User, this.friend});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController controller=EventController();
  late StreamSubscription<DatabaseEvent> EventsSubscription;
  String _sortCriterion = 'Name';
  List<Event> events=[];
  //Databaseclass db = Databaseclass();

  Future<void> fetchEventsFromLocalDb() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadEvents();
    if(widget.isOwner)widget.User = await Friend.getUserObject(widget.User.id!);
    else widget.friend = await Friend.getUserObject(widget.friend!.id!);
    if(mounted)setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final DatabaseReference _eventRef = FirebaseDatabase.instance.ref('Events');
    EventsSubscription=_eventRef.orderByChild('UserID').equalTo(widget.isOwner?widget.User.id!:widget.friend!.id).onValue.listen((event)async {
      if (event.snapshot.exists) {
        if(mounted)await fetchEventsFromLocalDb();
      }
    });
    _loadEvents();
  }
  @override
  void dispose() {
    // Cancel the listener when the widget is disposed
    EventsSubscription.cancel();
    super.dispose();
  }
  // Load the events initially
  void _loadEvents() async {
    List<Event> loadedEvents = await getEvents();
    if(mounted){
    setState(() {
      events = loadedEvents;
    }); }
  }

  Future<List<Event>> getEvents() async {
    if (widget.isOwner) {
      return await Friend.getEvents(widget.User.id!);
    } else {
      return await Friend.getEvents(widget.friend!.id);
    }
  }
  void _sortEvents() {
    events.sort((a, b) {
      switch (_sortCriterion) {
        case 'Category':
          return a.category.compareTo(b.category);
        case 'Status':
          return a.status.compareTo(b.status);
        case 'Name':
        default:
          return a.name.compareTo(b.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
        actions: [
          DropdownButton<String>(
            value: _sortCriterion,
            onChanged: (value) {
              setState(() {
                _sortCriterion = value!;
                _sortEvents();
              });
            },
            items: ['Name', 'Category', 'Status']
                .map((criterion) => DropdownMenuItem(
              value: criterion,
              child: Text('Sort by $criterion'),
            ))
                .toList(),
          ),
        ],
      ),
      body: events.isEmpty
          ? null
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          var event = events[index];
          return ListTile(
            title: Text(event.name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${event.status} - ${event.date?.toIso8601String().split('T')[0]}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isOwner && event.status=="Upcoming")
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async{
                      _editEvent(event);
                      await controller.SyncEventstoFirebase();
                    },
                  ),
                if (widget.isOwner)
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async{
                      _deleteEvent(event);
                      await controller.SyncDeletiontoFirebase(event.id!);
                    },
                  ),
              ],
            ),
            onTap: () async{
              await controller.GoToGiftList(event.id!, widget.isOwner, widget.User, context);
            },
          );
        },
      ),
      floatingActionButton: !widget.isOwner
          ? null
          : FloatingActionButton(
        onPressed: () {
          _addEvent();
        },
        backgroundColor: Colors.orangeAccent,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showEventDialog({Event? event}) {
    final nameController = TextEditingController(text: event?.name);
    final categoryController = TextEditingController(text: event?.category);
    final locationController = TextEditingController(text: event?.location);
    final descriptionController = TextEditingController(text: event?.description);

    DateTime? selectedDate = event?.date;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(event == null ? 'Add Event' : 'Edit Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Event Name'),
                    ),
                    TextField(
                      controller: categoryController,
                      decoration: InputDecoration(labelText: 'Category'),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await controller.PickEventDate(event, context);
                        if (pickedDate != null) {
                          if(mounted)
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 12.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate != null
                                      ? '${selectedDate!.toLocal()}'.split(' ')[0]
                                      : 'Select a date',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.calendar_today, color: Colors.blue),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(labelText: 'Location'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await controller.SaveEvent(nameController.text, categoryController.text
                        , locationController.text, descriptionController.text
                        , selectedDate, context, event, widget.User.id!);
                    _loadEvents();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addEvent() {
    _showEventDialog();
  }

  void _editEvent(Event event) {
    _showEventDialog(event: event);
  }

  Future<void> _deleteEvent(Event event) async {
    bool? success = await controller.deleteEvent(event);
    if (success ?? false) {
      showCustomSnackBar(context, "Event Deleted Successfully", backgroundColor: Colors.red);
      if(mounted)
      setState(() {
        events.remove(event);
      });
    } else {
      showCustomSnackBar(context, "Error Deleting Event", backgroundColor: Colors.red);
    }
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
