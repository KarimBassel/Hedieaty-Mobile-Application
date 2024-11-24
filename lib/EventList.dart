import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Friend.dart';
import 'package:hedieatymobileapplication/GiftList.dart';
import 'Base Classes/Event.dart';

class EventListPage extends StatefulWidget {
  final bool isOwner;
  Friend User;
  Friend? friend;
  EventListPage({required this.isOwner, required this.User, this.friend});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  String _sortCriterion = 'Name';

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
      body: ListView.builder(
        itemCount: (widget.isOwner == true)
            ? widget.User.eventlist!.length
            : widget.friend!.eventlist!.length,
        itemBuilder: (context, index) {
          final event = (widget.isOwner == true)
              ? widget.User.eventlist![index]
              : widget.friend!.eventlist![index];
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
                  child: Text('${event.category} - ${event.status}',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isOwner)
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _editEvent(event);
                    },
                  ),
                if (widget.isOwner)
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteEvent(event);
                    },
                  ),
              ],
            ),
            onTap: () {
              if (widget.isOwner) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GiftListPage(
                        event: event,
                        isOwner: widget.isOwner,
                        User: widget.User,
                      )),
                );
              }

              else{
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GiftListPage(
                        event: event,
                        isOwner: widget.isOwner,
                        User: widget.User,
                        friend: widget.friend,
                      )),
                );
              }
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

  void _sortEvents() {
    setState(() {
      widget.User.eventlist!.sort((a, b) {
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
    });
  }

  void _showEventDialog({Event? event}) async {
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
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
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
                    final name = nameController.text;
                    final category = categoryController.text;
                    final location = locationController.text;
                    final description = descriptionController.text;

                    if (selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a date')),
                      );
                      return;
                    }

                    final DateTime today = DateTime.now();
                    final String status = selectedDate!.isBefore(today)
                        ? 'Completed'
                        : 'Upcoming';

                    if (event == null) {
                      // Add new event
                      widget.User.eventlist!.add(Event(
                        name: name,
                        category: category,
                        status: status,
                        date: selectedDate,
                        location: location,
                        description: description,
                        userId: widget.User.id,
                      ));

                      await Event.insertEvent(Event(
                        name: name,
                        category: category,
                        status: status,
                        date: selectedDate,
                        location: location,
                        description: description,
                        userId: widget.User.id,
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

                    // Reload user data and refresh event list
                    widget.User = await Friend.getUserObject(widget.User.id!);
                    widget.User.eventlist = await Friend.getEvents(widget.User.id!);
                    setState(() {
                      widget.User.eventlist = widget.User.eventlist;
                    });

                    Navigator.of(context).pop();
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
    setState(() {});
  }

  void _editEvent(Event event) {
    _showEventDialog(event: event);
    setState(() {});
  }

  void _deleteEvent(Event event) async {
    bool? deletestatus = await Event.deleteEvent(event.id!);
    showCustomSnackBar(context, "Event Deleted Successfully", backgroundColor: Colors.green);
    setState(() {
      widget.User.eventlist!.remove(event);
    });
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
