import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Authentication.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Database.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Gift.dart';
import 'package:hedieatymobileapplication/EventList.dart';
import 'package:hedieatymobileapplication/MyPledgedGifts.dart';
import 'package:hedieatymobileapplication/SignIn.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Base Classes/Friend.dart';

class Profile extends StatefulWidget {
  Friend User;
  Profile({required this.User});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _image;
  bool switchstate=false;
  AuthService auth = AuthService();
  Databaseclass db = Databaseclass();
  TextEditingController _nameController = TextEditingController(text: "Cristiano Ronaldo");
  TextEditingController _emailController = TextEditingController(text: "Cristiano@eng.asu.edu.eg");
  TextEditingController _preferencesController = TextEditingController(text: "Electronics, Sports");



  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final imagebytes = await File(pickedImage.path).readAsBytes();
      String encodedim = base64Encode(imagebytes);

      bool update = await Friend.updateUser(widget.User.id!,"Image",encodedim);
      Friend? updateduser = await Friend.getUserById(widget.User.id!);
      widget.User=updateduser!;
      db.syncUsersTableToFirebase();
      setState(() {
        _image = File(pickedImage.path);


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
              onPressed: () async{
                bool update = await Friend.updateUser(widget.User.id!,field,controller.text);
                Friend? updateduser = await Friend.getUserById(widget.User.id!);
                widget.User=updateduser!;

                db.syncUsersTableToFirebase();
                setState(() {});
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
    _nameController.text = widget.User.name;
    _emailController.text = widget.User.email!;
    _preferencesController.text = widget.User.preferences!;
    switchstate = (widget.User.notifications==0)?false:true;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "User Details",
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar
          CircleAvatar(
            radius: 150,
            backgroundImage: widget.User.image != null
                ? MemoryImage(base64Decode(widget.User.image!.split(',').last))
                : NetworkImage(
              'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1729004634~exp=1729005234~hmac=cb0fb1a6e2dd8ce69411b07aecac4347fa1bad93feb2cbbe5070ef06955202d8',
            ) as ImageProvider,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _pickImage,
            iconSize: 30,
          ),
          SizedBox(height: 10),

          // Name Card
          _buildProfileCard('Name', _nameController),

          SizedBox(height: 10),

          // Email Card
          _buildProfileCard('Email', _emailController),

          SizedBox(height: 10),

          // Preferences Card
          _buildProfileCard('Preferences', _preferencesController),

          SizedBox(height: 10),

          // Notifications Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: switchstate,
                    onChanged: (value) async{
                      bool update = await Friend.updateUser(widget.User.id!,"Notifications",(value==false)?0:1);
                      Friend? updateduser = await Friend.getUserObject(widget.User.id!);
                      widget.User=updateduser!;

                      db.syncUsersTableToFirebase();

                      setState(() {
                        switchstate = value;
                      });
                    },
                    activeTrackColor: Colors.amber[100],
                    activeColor: Colors.amber[900],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          _buildNavigationButton("Go to Events List", ()async {
            Friend? updateduser = await Friend.getUserObject(widget.User.id!);
            widget.User=updateduser!;
            Navigator.push(context, MaterialPageRoute(builder: (context) => EventListPage(isOwner: true,User: widget.User,)));
          }),

          SizedBox(height: 20),


          _buildNavigationButton("My Pledged Gifts", () async{
            List<Gift> plgf = await Friend.getPledgedGiftsWithEventDetails(widget.User.id!);
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyPledgedGifts(pledgedgifts:plgf)));
          }),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: (){
              auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => SignIn()),
                    (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child: Text(
              "SignOut",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String title, TextEditingController controller) {
    return Card(
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
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    controller.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey[700],
                    ),
                  ),
                ],
              ),
            ),
            if(title!='Email')_buildEditIcon(title, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(String title, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
