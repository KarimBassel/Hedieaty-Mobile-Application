import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/EventList.dart';
import 'package:hedieatymobileapplication/MyPledgedGifts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class Profile extends StatefulWidget{
  @override
  _ProfileState createState() => _ProfileState();
}
class _ProfileState extends State<Profile>{
  File? _image;
  TextEditingController _nameController = TextEditingController(text: "Cristiano Ronaldo");
  TextEditingController _emailController = TextEditingController(text: "Cristiano@eng.asu.edu.eg");
  TextEditingController _preferencesController = TextEditingController(text : "Electronics, Sports");

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();

    final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image =
            File(pickedImage.path);
      });
    }
  }

  Widget _buildEditIcon(String label, TextEditingController controller) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        _editField(label, controller);
      },
    );
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
            "User Details",
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
                      'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1729004634~exp=1729005234~hmac=cb0fb1a6e2dd8ce69411b07aecac4347fa1bad93feb2cbbe5070ef06955202d8',
                    ) as ImageProvider,
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: _pickImage,
                    color: Colors.blue,
                    iconSize: 30,
                  ),

                  SizedBox(height: 10),

                  // Name Card
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
                          _buildEditIcon('Name', _nameController),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Email Card
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
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _emailController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildEditIcon('Email', _emailController),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Preferences Card
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
                                  'Preferences',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _preferencesController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildEditIcon('Preferences', _preferencesController),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        //print(MediaQuery.sizeOf(context).width);
                        //print(MediaQuery.sizeOf(context).height);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> EventListPage(isOwner: true,)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,

                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "Go to Events List",
                        style: TextStyle(
                          fontSize: 18, // Font size
                          fontWeight: FontWeight.bold, // Bold text
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> MyPledgedGifts()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan, // Button background color

                        padding: EdgeInsets.symmetric(vertical: 15), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "My Pledged Gifts",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
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