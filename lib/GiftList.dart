import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/EventList.dart';
import 'package:hedieatymobileapplication/GiftDetails.dart';
import 'package:image_picker/image_picker.dart';
import 'Base Classes/Gift.dart';
import 'Base Classes/Event.dart';


class GiftListPage extends StatefulWidget {
  final Event event;
  final bool isOwner;

  GiftListPage({required this.event,required this.isOwner});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> gifts = [
    Gift(name: 'Car', category: 'Toys', status: 'Available', description: 'Toy car', price: 20.0,),
    Gift(name: 'Atomic Habits', category: 'Books', status: 'Pledged', description: 'Storybook', price: 15.0),
    Gift(name: 'Iphone 15', category: 'Electronics', status: 'Available', description: 'Headphones', price: 50.0),
  ];

  String _sortCriterion = 'Name';
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Gifts for ${widget.event.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Event: ${widget.event.name}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Category: ${widget.event.category}', style: TextStyle(fontSize: 16)),
            Text('Status: ${widget.event.status}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16.0),
            Divider(),

            DropdownButton<String>(
              value: _sortCriterion,
              onChanged: (value) {
                setState(() {
                  _sortCriterion = value!;
                  _sortGifts();
                });
              },
              items: ['Name', 'Category', 'Status']
                  .map((criterion) => DropdownMenuItem(
                value: criterion,
                child: Text('Sort by $criterion'),
              ))
                  .toList(),
            ),
            SizedBox(height: 8.0),

            // Gifts List
            Expanded(
              child: ListView.builder(
                itemCount: gifts.length,
                itemBuilder: (context, index) {
                  final gift = gifts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: gift.status == 'Pledged' ? Colors.amber[100] : Colors.white,
                    child: ListTile(
                      leading: gift.image != null
                          ? Image.file(gift.image!, width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.image, size: 50),
                      title: Text(gift.name,style: TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('${gift.category}',style: TextStyle(fontSize: 10,color: Colors.white),)),

                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if(widget.isOwner && gift.status=="Available")
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editGift(gift),
                          ),
                          if(widget.isOwner && gift.status=="Available")
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteGift(gift),
                          ),
                        ],
                      ),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => GiftDetails(gift: gift,isOwner: widget.isOwner,isPledged: gift.status =="Pledged"?true : false,)));
                      },
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: !widget.isOwner? null :
      FloatingActionButton(
        onPressed: _addGift,
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  void _sortGifts() {
    setState(() {
      gifts.sort((a, b) {
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

  void _showGiftDialog({Gift? gift}) async {
    final nameController = TextEditingController(text: gift?.name);
    final categoryController = TextEditingController(text: gift?.category);
    final statusController = TextEditingController(text: gift?.status);
    final descriptionController = TextEditingController(text: gift?.description);
    final priceController = TextEditingController(text: gift?.price.toString());

    File? imageFile = gift?.image;

    void _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(gift == null ? 'Add Gift' : 'Edit Gift'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Gift Name')),
                TextField(controller: categoryController, decoration: InputDecoration(labelText: 'Category')),
                TextField(controller: statusController, decoration: InputDecoration(labelText: 'Status')),
                TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
                TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price')),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                if (imageFile != null) Image.file(imageFile!, width: 100, height: 100),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                setState(() {
                  if (gift == null) {
                    gifts.add(Gift(
                      name: nameController.text,
                      category: categoryController.text,
                      status: statusController.text,
                      description: descriptionController.text,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      image: imageFile,
                    ));
                  } else {
                    gift.name = nameController.text;
                    gift.category = categoryController.text;
                    gift.status = statusController.text;
                    gift.description = descriptionController.text;
                    gift.price = double.tryParse(priceController.text) ?? gift.price;
                    gift.image = imageFile;
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

  void _addGift() => _showGiftDialog();

  void _editGift(Gift gift) => _showGiftDialog(gift: gift);

  void _deleteGift(Gift gift) {
    setState(() {
      gifts.remove(gift);
    });
  }
}
