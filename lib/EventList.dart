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
  List<Event> events=[];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Load the events initially
  void _loadEvents() async {
    List<Event> loadedEvents = await getEvents();
    setState(() {
      events = loadedEvents;
    });
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
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftListPage(
                    event: event,
                    isOwner: widget.isOwner,
                    User: widget.User,
                    friend: widget.friend,
                  ),
                ),
              );
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
                    Navigator.of(context).pop();
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
    bool? success = await Event.deleteEvent(event.id!);
    if (success ?? false) {
      showCustomSnackBar(context, "Event Deleted Successfully", backgroundColor: Colors.red);
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
            Icons.error_outline,  // Customize the icon
            color: Colors.white,
          ),
          SizedBox(width: 8), // Add some space between the icon and the text
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,  // Ensure the text doesn't overflow
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,  // Set the background color
      duration: Duration(seconds: 3), // Duration the SnackBar will be shown
      behavior: SnackBarBehavior.floating, // Makes the SnackBar float above other widgets
      margin: EdgeInsets.all(16),  // Add some margin around the SnackBar
      shape: RoundedRectangleBorder(  // Rounded corners for the SnackBar
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
