import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GiftDetails extends StatefulWidget {
  bool isOwner;
  bool isPledged;
  GiftDetails({super.key, this.isOwner = true,this.isPledged=false});

  @override
  _GiftDetailsState createState() => _GiftDetailsState();
}

class _GiftDetailsState extends State<GiftDetails> {
  File? _image;
  final TextEditingController _nameController = TextEditingController(text: 'iPhone 15');
  final TextEditingController _descriptionController = TextEditingController(text:
  'The iPhone 15 has a 6.1-inch display, 48MP main camera, A16 Bionic chip, and USB-C port. It supports Dynamic Island, runs iOS 17, and starts at 799.');
  final TextEditingController _categoryController = TextEditingController(text: 'Electronics');
  final TextEditingController _priceController = TextEditingController(text: '1200');


  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        print(pickedImage.path);
      });
    }
  }

  void _editField(String field, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter $field"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  //to update controller.text
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(
            "Gift Details",
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // Avatar
                  CircleAvatar(
                    radius: 150,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : NetworkImage(
                        'https://shop.switch.com.my/cdn/shop/files/iPhone_15_Pink_PDP_Image_Position-1__GBEN_7cf60425-0d5a-4bc9-bfd9-645b9c86e68e.jpg?v=1717694179&width=823')
                    as ImageProvider,
                  ),
                  if (widget.isOwner && !widget.isPledged)
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _pickImage,
                      color: Colors.blue,
                      iconSize: 30,
                    ),
                  SizedBox(height: 10),

                  Center(
                    child: Text(
                      widget.isPledged ? 'Pledged' : 'Available',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: widget.isPledged ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _nameController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.isOwner && !widget.isPledged)
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editField('Name', _nameController);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),


                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[900],
                                ),
                              ),
                              if (widget.isOwner && !widget.isPledged)
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _editField('Description', _descriptionController);
                                  },
                                ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            _descriptionController.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Category',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey[900],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        _categoryController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blueGrey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.isOwner && !widget.isPledged)
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _editField('Category', _categoryController);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Price',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey[900],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        _priceController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blueGrey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.isOwner && !widget.isPledged)
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _editField('Price', _priceController);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Buttons Row
                  if(!widget.isOwner && !widget.isPledged)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              "Pledge",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}