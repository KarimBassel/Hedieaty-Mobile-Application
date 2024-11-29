import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Database.dart';
import 'package:image_picker/image_picker.dart';
import 'Base Classes/Gift.dart';
import 'Base Classes/Event.dart';
import 'Base Classes/Friend.dart';
import 'GiftDetails.dart';

class GiftListPage extends StatefulWidget {
  Event event;
  Friend User;
  final bool isOwner;

  GiftListPage({required this.event, required this.isOwner, required this.User});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final ImagePicker _picker = ImagePicker();
  String _sortCriterion = 'Name';
  Databaseclass db = Databaseclass();

  Future<void> fetchGiftsFromLocalDb() async {
    await Future.delayed(const Duration(seconds: 1));
    Event? e = await Event.getEventById(widget.event.id!);
    widget.event = e!;
    setState(() {});
  }


  @override
  void initState() {

    final DatabaseReference _giftsRef = FirebaseDatabase.instance.ref('Gifts');
    _giftsRef.orderByChild('EventID').equalTo(widget.event.id).onValue.listen((event)async {
      if (event.snapshot.exists) {
        await fetchGiftsFromLocalDb();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gifts for ${widget.event.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLandscape?
            //if orientation is landscape
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('Event: ${widget.event.name}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Category: ${widget.event.category}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Date: ${widget.event.date
                      ?.toIso8601String().split('T')[0]}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  //Text('Description: ${widget.event.description}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Status: ${widget.event.status}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Location: ${widget.event.location}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                ],
              ),
            ),

            // Gifts List
            Expanded(
              child: ListView.builder(
                itemCount: widget.event.giftlist!.length,
                itemBuilder: (context, index) {
                  final gift = widget.event.giftlist![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: gift.status == 'Pledged' ? Colors.red[100] : Colors.white,
                    child: ListTile(
                      leading: gift.image != null
                          ?  CircleAvatar(
                        radius: 25,
                        backgroundImage: MemoryImage(base64Decode(gift.image!.split(',').last)),
                      ) : Icon(Icons.image, size: 50),
                      title: Text(gift.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('${gift.category}', style: TextStyle(fontSize: 10, color: Colors.white)),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.isOwner && gift.status == "Available")
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () async{
                                  _editGift(gift);
                                  setState(() {

                                  });
                                }
                            ),
                          if (widget.isOwner && gift.status == "Available")
                            IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: ()async {
                                  _deleteGift(gift);
                                  setState(() {

                                  });
                                }
                            ),
                        ],
                      ),
                      onTap: () async{
                        if(widget.isOwner){
                          print("okash");
                          List<Gift> updatedlist = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GiftDetails(gift: gift, isOwner: widget.isOwner, isPledged: gift.status == "Pledged" ? true : false,
                                isPledger: false,User: widget.User,))
                          );
                          setState(() {
                            widget.event.giftlist=updatedlist;
                          });
                        }
                        else{
                          print(widget.User!.PhoneNumber);
                          print(gift.PledgerID);
                          print(widget.User.id);
                          List<Gift> updatedlist = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GiftDetails(gift: gift, isOwner: widget.isOwner, isPledged: gift.status == "Pledged" ? true : false,
                                isPledger: (gift.PledgerID==widget.User.id)?true:false,User: widget.User,))
                          );

                          setState(() {
                            widget.event.giftlist=updatedlist;
                          });
                        }

                      },
                    ),
                  );
                },
              ),
            ),
          ],
        )


//if orientation is portrait

        : Column(
          children: [
            Text('Event: ${widget.event.name}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Category: ${widget.event.category}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Date: ${widget.event.date
                ?.toIso8601String().split('T')[0]}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            //Text('Description: ${widget.event.description}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Status: ${widget.event.status}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Location: ${widget.event.location}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    color: gift.status == 'Pledged' ? Colors.red[100] : Colors.white,
                    child: ListTile(
                      leading: gift.image != null
                          ?  CircleAvatar(
                        radius: 25,
                        backgroundImage: MemoryImage(base64Decode(gift.image!.split(',').last)),
                      ) : Icon(Icons.image, size: 50),
                      title: Text(gift.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('${gift.category}', style: TextStyle(fontSize: 10, color: Colors.white)),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.isOwner && gift.status == "Available")
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: ()async {
                                  _editGift(gift);
                                  setState(() {

                                  });
                                }
                            ),
                          if (widget.isOwner && gift.status == "Available")
                            IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async{
                                  _deleteGift(gift);
                                  setState(() {

                                  });
                                }
                            ),
                        ],
                      ),
                      onTap: () async{
                        if(widget.isOwner){
                          print("okash");
                          List<Gift> updatedlist = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GiftDetails(gift: gift, isOwner: widget.isOwner, isPledged: gift.status == "Pledged" ? true : false,
                                isPledger: false,User: widget.User,))
                          );
                          setState(() {
                            widget.event.giftlist=updatedlist;
                          });
                        }
                        else{
                          print(widget.User!.PhoneNumber);
                          print(gift.PledgerID);
                          print(widget.User.id);
                          List<Gift> updatedlist = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GiftDetails(gift: gift, isOwner: widget.isOwner, isPledged: gift.status == "Pledged" ? true : false,
                                isPledger: (gift.PledgerID==widget.User.id)?true:false,User: widget.User,))
                          );

                          setState(() {
                            widget.event.giftlist=updatedlist;
                          });
                        }

                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !widget.isOwner
          ? null
          : FloatingActionButton(
        onPressed: ()async{
          _addGift();
          await db.syncGiftsTableToFirebase();
          setState(() {

          });
        } ,
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.add, color: Colors.white),
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
    final descriptionController = TextEditingController(text: gift?.description);
    final priceController = TextEditingController(text: gift?.price.toString());


    String status = gift?.status ?? 'Available';
    final List<String> statusOptions = ['Available', 'Pledged'];


    File? imageFile;


    String? encodedImage = gift?.image;


    void _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    }

    Image? _getBase64Image(String base64Image) {
      try {

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
                TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
                TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price')),
                Center(
                  child: IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: _pickImage,
                  ),
                ),
                SizedBox(height: 10),
                // Display the image (either base64 or selected image)
                if (gift?.image != null && gift?.image!.isNotEmpty == true)
                  _getBase64Image(gift!.image!)!,
                if (imageFile != null) Image.file(imageFile!, width: 100, height: 100),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                // Check if an image is selected and encode it
                if (imageFile != null) {
                  final imageBytes = await File(imageFile!.path).readAsBytes();
                  encodedImage = base64Encode(imageBytes);
                }

                if (gift == null) {
                  // Adding a new gift
                  widget.event.giftlist!.add(Gift(
                    name: nameController.text,
                    category: categoryController.text,
                    status: status,
                    description: descriptionController.text,
                    price: int.tryParse(priceController.text) ?? 0,
                    image: encodedImage ?? '',
                    eventId: widget.event.id,
                  ));

                  bool addGift = await Gift.addGift(Gift(
                    name: nameController.text,
                    category: categoryController.text,
                    status: status,
                    description: descriptionController.text,
                    price: int.tryParse(priceController.text) ?? 0,
                    image: encodedImage ?? '',
                    eventId: widget.event.id,
                  ));


                  showCustomSnackBar(context, "Gift Added Successfully", backgroundColor: Colors.green);
                } else {
                  // Editing an existing gift
                  gift.name = nameController.text;
                  gift.category = categoryController.text;
                  gift.status = status;
                  gift.description = descriptionController.text;
                  gift.price = int.tryParse(priceController.text) ?? gift.price;
                  gift.image = encodedImage ?? gift.image;

                  bool updateStatus = await Gift.updateGift(gift);


                  showCustomSnackBar(context, "Gift Updated Successfully", backgroundColor: Colors.green);
                }
                widget.event.giftlist = await Gift.getGiftList(widget.event.id!);
                await db.syncGiftsTableToFirebase();

                setState(() {

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

  void _deleteGift(Gift gift) async{
    bool delgift = await Gift.DeleteGift(gift.id!);
    widget.event.giftlist = await Gift.getGiftList(widget.event.id!);
    setState(() {

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