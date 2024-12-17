import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hedieatymobileapplication/Database.dart';
import 'package:image_picker/image_picker.dart';
import '../Controllers/GiftController.dart';
import '../Models/Gift.dart';

import '../Models/Event.dart';
import '../Models/Friend.dart';
import 'GiftDetails.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class GiftListPage extends StatefulWidget {
  Event event;
  Friend User;
  final bool isOwner;

  GiftListPage({required this.event, required this.isOwner, required this.User});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftController controller = GiftController();
  final ImagePicker _picker = ImagePicker();
  String _scanBarcode = 'Unknown';
  String _sortCriterion = 'Name';
  String result='';
  late StreamSubscription<DatabaseEvent> _giftsSubscription;

  Future<void> fetchGiftsFromLocalDb() async {
    await Future.delayed(const Duration(seconds: 1));
    Event? e = await controller.fetchGiftsFromLocalDb(widget.event.id!);
    widget.event = e!;
    if(mounted){
    setState(() {}); }
  }


  @override
  void initState(){

    final DatabaseReference _giftsRef = FirebaseDatabase.instance.ref('Gifts');
    _giftsSubscription=_giftsRef.orderByChild('EventID').equalTo(widget.event.id).onValue.listen((event)async {
      if (event.snapshot.exists) {
        await fetchGiftsFromLocalDb();
      }
    });
    //await controller.InitiateGiftsFirebaseListener(context);
  }
  @override
  void dispose() {
    // Cancel the listener when the widget is disposed
    _giftsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gifts for ${widget.event.name}'),
        actions: [
          if(widget.isOwner && widget.event.status=="Upcoming")
          IconButton(onPressed: ()async{
            dynamic ress = await controller.ScanBarcode(context,widget.event.id!,widget.event.userId!);
            if(ress is List<Gift>)widget.event.giftlist=ress;
            //print(res);
            if(mounted)
              setState(() {

              });
          }, icon: Icon(Icons.barcode_reader),tooltip: "Barcode Reader",)

        ],
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
                        radius: 22,
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
                          if (widget.isOwner && gift.status == "Available" && widget.event.status=="Upcoming"&& gift.IsPublished==0)
                            IconButton(onPressed: ()async{
                              widget.event.giftlist=await controller.PublishGift(gift);
                              if (mounted) {
                                setState(() {});
                              }
                              await controller.syncGiftsTableToFirebase();
                            }, icon: Icon(Icons.publish),tooltip: "Publish",),
                          if(widget.isOwner && gift.status == "Available" && widget.event.status=="Upcoming"&& gift.IsPublished==1)
                            IconButton(onPressed: ()async{
                              widget.event.giftlist=await controller.UnPublishGift(gift);
                              if (mounted) {
                                setState(() {});
                              }
                              await controller.syncGiftsTableToFirebase();
                            }, icon: Icon(Icons.unpublished),tooltip: "UnPublish",),
                          if (widget.isOwner && gift.status == "Available" && widget.event.status=="Upcoming")
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () async{
                                  _editGift(gift);
                                  if(mounted)
                                  setState(() {

                                  });
                                }
                            ),
                          if (widget.isOwner && gift.status == "Available" && widget.event.status=="Upcoming")
                            IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: ()async {
                                  _deleteGift(gift);
                                  if(mounted)
                                  setState(() {

                                  });
                                }
                            ),
                        ],
                      ),
                      onTap: widget.event.status=="Upcoming" ?() async{
                        widget.event=await controller.OnGiftCardTap(widget.isOwner, context, gift, gift.status, widget.User, widget.event.id!);
                        if(mounted)
                        setState(() {

                        });
                      } : (){controller.showCustomSnackBar(context,"Event Completed!");},
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
                        radius: 22,
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
                          if (widget.isOwner && gift.status == "Available" && widget.event.status=="Upcoming"&& gift.IsPublished==0)
                            IconButton(onPressed: ()async{
                              widget.event.giftlist=await controller.PublishGift(gift);
                              if (mounted) {
                                setState(() {});
                              }
                              await controller.syncGiftsTableToFirebase();
                            }, icon: Icon(Icons.publish),tooltip: "Publish",),
                          if(widget.isOwner && gift.status == "Available" && widget.event.status=="Upcoming"&& gift.IsPublished==1)
                            IconButton(onPressed: ()async{
                              widget.event.giftlist=await controller.UnPublishGift(gift);
                              if (mounted) {
                                setState(() {});
                              }
                              await controller.syncGiftsTableToFirebase();
                            }, icon: Icon(Icons.unpublished),tooltip: "UnPublish",),
                          if (widget.isOwner && gift.status == "Available" && widget.event.status=="Upcoming")
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () async{
                                  _editGift(gift);
                                  if(mounted)
                                    setState(() {

                                    });
                                },tooltip: "Edit",
                            ),
                          if (widget.isOwner && gift.status == "Available" && widget.event.status=="Upcoming")
                            IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: ()async {
                                  _deleteGift(gift);
                                  if(mounted)
                                    setState(() {

                                    });
                                },tooltip: "Delete"
                            ),
                        ],
                      ),
                      onTap: widget.event.status=="Upcoming"? () async{
                          widget.event=await controller.OnGiftCardTap(widget.isOwner, context, gift, gift.status, widget.User, widget.event.id!);
                          if(mounted)
                          setState(() {

                          });
                      } : (){controller.showCustomSnackBar(context,"Event Completed!");},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !widget.isOwner || widget.event.status=="Completed"
          ? null
          :
              FloatingActionButton(
                      onPressed: ()async{
              _addGift();
              if(mounted)
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
    final _formKey = GlobalKey<FormState>(); // Form key for validation
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
        if (mounted) {
          setState(() {
            imageFile = File(pickedFile.path);
          });
        }
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Gift Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a gift name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      counterText: '', // To hide the default character counter
                    ),
                    maxLength: 10, // Restricts the input to 10 characters
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a category';
                      }
                      if (value.length > 10) {
                        return 'Category cannot exceed 10 characters'; // Error message if length is more than 10
                      }
                      return null; // Valid input
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Please enter a valid price greater than zero';
                      }
                      return null;
                    },
                  ),
                  Center(
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _pickImage,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (gift?.image != null && gift?.image!.isNotEmpty == true)
                    _getBase64Image(gift!.image!)!,
                  if (imageFile != null) Image.file(imageFile!, width: 100, height: 100),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState?.validate()==true && imageFile!=null) {
                  await controller.OnSaveGiftPressed(imageFile, encodedImage, gift, widget.event, nameController, categoryController, descriptionController, priceController, status, context,);
                  //controller.showCustomSnackBar(context, "Gift Added/Updated Successfully", backgroundColor: Colors.green);
                  widget.event.giftlist = await controller.GetGiftList(widget.event.id!);
                  if (mounted) {
                    setState(() {});
                  }
                  CircularProgressIndicator();
                  await controller.syncGiftsTableToFirebase();
                }
                if(imageFile==null)
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('No Image Selected'),
                        content: Text('Please select an image for the gift.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
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
    widget.event.giftlist = await controller.DeleteGift(gift, widget.event.id!);
    if(mounted)
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