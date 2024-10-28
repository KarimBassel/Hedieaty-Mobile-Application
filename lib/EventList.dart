import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/GiftList.dart';
import 'Base Classes/Event.dart';

class EventListPage extends StatefulWidget {
  final bool isOwner;
  EventListPage({required this.isOwner});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {

  List<Event> events = [
    Event(name: 'Conference', category: 'Business', status: 'Upcoming'),
    Event(name: 'Birthday Party', category: 'Personal', status: 'Past'),
    Event(name: 'Workshop', category: 'Education', status: 'Current'),
  ];

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
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(event.name,style: TextStyle(fontWeight: FontWeight.bold),),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // padding for spacing
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent, // background color
                      borderRadius: BorderRadius.circular(12), // rounded edges
                    ),
                    child: Text('${event.category} - ${event.status}',style: TextStyle(color: Colors.white),)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if(widget.isOwner)
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editEvent(event),
                ),
                if(widget.isOwner)
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteEvent(event),
                ),
              ],
            ),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => GiftListPage(event: event,isOwner: widget.isOwner,)));
            },
          );
        },
      ),
      floatingActionButton: !widget.isOwner? null :
      FloatingActionButton(
        onPressed: _addEvent,
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  void _sortEvents() {
    setState(() {
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
    });
  }
  void _showEventDialog({Event? event}) {
    final nameController = TextEditingController(text: event?.name);
    final categoryController = TextEditingController(text: event?.category);
    final statusController = TextEditingController(text: event?.status);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event == null ? 'Add Event' : 'Edit Event'),
          content: Column(
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
              TextField(
                controller: statusController,
                decoration: InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final category = categoryController.text;
                final status = statusController.text;

                setState(() {
                  if (event == null) {
                    events.add(Event(name: name, category: category, status: status));
                  } else {
                    event.name = name;
                    event.category = category;
                    event.status = status;
                  }
                });

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
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
  void _deleteEvent(Event event) {
    setState(() {
      events.remove(event);
    });
  }
}
