import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/EventList.dart';
import 'package:hedieatymobileapplication/GiftDetails.dart';
import 'package:image_picker/image_picker.dart';
import 'Base Classes/Gift.dart';
import 'Base Classes/Event.dart';
import 'Base Classes/Friend.dart';

class GiftListPage extends StatefulWidget {
  Event event;
  Friend User;
  Friend? friend;
  final bool isOwner;

  GiftListPage({required this.event,required this.isOwner,required this.User,this.friend});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  // List<Gift> gifts = [
  //   Gift(name: 'Car', category: 'Toys', status: 'Available', description: 'Toy car', price: 20,),
  //   Gift(name: 'Atomic Habits', category: 'Books', status: 'Pledged', description: 'Storybook', price: 15),
  //   Gift(name: 'Iphone 15', category: 'Electronics', status: 'Available', description: 'Headphones', price: 50),
  // ];

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
            //Text('Status: ${widget.event.status}', style: TextStyle(fontSize: 16)),
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
                itemCount: widget.event.giftlist!.length,
                itemBuilder: (context, index) {
                  final gift = widget.event.giftlist![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: gift.status == 'Pledged' ? Colors.amber[100] : Colors.white,
                    child: ListTile(
                      leading: gift.image != null
                          ? Image.memory(base64Decode(gift.image!.split(',').last))
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
      widget.event.giftlist!.sort((a, b) {
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

    // Variable to store the selected image file
    File? imageFile;

    // Function to pick an image from the gallery
    void _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    }

    // Decode base64 image if the gift has an image
    Image? _getBase64Image(String base64Image) {
      try {
        // Decode the base64 string to bytes and display the image
        Uint8List bytes = base64Decode(base64Image);
        return Image.memory(bytes);
      } catch (e) {
        print("Error decoding base64 image: $e");
        return null;
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
                // Display the image (either base64 or selected image)
                if (gift?.image != null && gift?.image!.isNotEmpty == true)
                  _getBase64Image(gift!.image!)!,
                if (imageFile != null)
                  Image.file(imageFile!, width: 100, height: 100),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                final imagebytes = await File(imageFile!.path).readAsBytes();
                String encodedim = base64Encode(imagebytes);

                if (gift == null) {
                  // Adding a new gift
                  widget.event.giftlist!.add(Gift(
                    name: nameController.text,
                    category: categoryController.text,
                    status: statusController.text,
                    description: descriptionController.text,
                    price: int.tryParse(priceController.text) ?? 0,
                    image: encodedim,
                    eventId: widget.event.id,
                  ));

                  bool addgift = await Gift.addGift(Gift(
                    name: nameController.text,
                    category: categoryController.text,
                    status: statusController.text,
                    description: descriptionController.text,
                    price: int.tryParse(priceController.text) ?? 0,
                    image: encodedim,
                    eventId: widget.event.id,
                  ));
                } else {
                  // Editing an existing gift
                  gift.name = nameController.text;
                  gift.category = categoryController.text;
                  gift.status = statusController.text;
                  gift.description = descriptionController.text;
                  gift.price = int.tryParse(priceController.text) ?? gift.price;
                  gift.image = encodedim;
                }

                setState(() {});
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
      widget.event.giftlist!.remove(gift);
    });
  }
}
