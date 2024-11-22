import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Database.dart';
import 'package:image_picker/image_picker.dart';
import 'SignIn.dart';
import 'Base Classes/Friend.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Signup extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<Signup> {

  Databaseclass db= Databaseclass();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
//   Future<Database> initialize() async {
//     String mypath = await getDatabasesPath();
//     print(mypath);
//     String path = join(mypath, 'hedieaty.db');
//     Database mydb = await openDatabase(path, version: 1,
//         onCreate: (db, Version) async {
//           db.execute('''
//                   CREATE TABLE Users (
//   ID INTEGER PRIMARY KEY AUTOINCREMENT,
//   Name TEXT NOT NULL,
//   Email TEXT UNIQUE NOT NULL,
//   Preferences TEXT,
//   PhoneNumber TEXT NOT NULL,
//   Password TEXT NOT NULL
// );
//
// CREATE TABLE Events (
//   ID INTEGER PRIMARY KEY AUTOINCREMENT,
//   Name TEXT NOT NULL,
//   Date TEXT NOT NULL,
//   Location TEXT,
//   Description TEXT,
//   UserID INTEGER NOT NULL,
//   FOREIGN KEY (UserID) REFERENCES Users(ID)
// );
//
// CREATE TABLE Gifts (
//   ID INTEGER PRIMARY KEY AUTOINCREMENT,
//   Name TEXT NOT NULL,
//   Description TEXT,
//   Category TEXT,
//   Price REAL,
//   Status TEXT NOT NULL,
//   EventID INTEGER NOT NULL,
//   FOREIGN KEY (EventID) REFERENCES Events(ID)
// );
//
// CREATE TABLE Friends (
//   UserID INTEGER NOT NULL,
//   FriendID INTEGER NOT NULL,
//   PRIMARY KEY (UserID, FriendID),
//   FOREIGN KEY (UserID) REFERENCES Users(ID),
//   FOREIGN KEY (FriendID) REFERENCES Users(ID)
// );
//       ''');
//           print("Database has been created .......");
//         });
//     return mydb;
//   }

  void _submitForm(BuildContext context) async{
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String preferences = _preferencesController.text.trim();
      final String phoneNumber = _phoneNumberController.text.trim();
      final String password = _passwordController.text.trim();
      final File? image = _selectedImage;
      final imagebytes = await File(image!.path).readAsBytes();
      String encodedim = base64Encode(imagebytes);

      if(await Friend.getUserByPhoneNumber(phoneNumber)){
        showCustomSnackBar(context, "Phone number already registered");
      }
      else{
        print(await db.insertData("INSERT INTO Users (Name, Email, Preferences, PhoneNumber, Password,Image,Notifications,UpcomingEvents) VALUES ('${name}', '${email}', '${preferences}', '${phoneNumber}', '${password}','${encodedim}',0,0);"));
        showCustomSnackBar(context, "Account Registered Successfully!",backgroundColor: Colors.green);
        _nameController.clear();
        _emailController.clear();
        _preferencesController.clear();
        _phoneNumberController.clear();
        _passwordController.clear();
        image.delete();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Signup()));
        // await db.insertData("INSERT INTO Friends (UserID, FriendID) VALUES ('1', '2');");
        // await db.insertData("INSERT INTO Friends (UserID, FriendID) VALUES ('2', '1');");
        print("User inserted successfully");
      }


      // Handle sign-up logic
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Signup for Hedieaty App')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16),
                // Simple Image Picker Icon
                Center(
                  child: IconButton(
                    onPressed: _pickImage,
                    icon: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Preferences Field
                TextFormField(
                  controller: _preferencesController,
                  decoration: InputDecoration(
                    labelText: 'Preferences',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // Phone Number Field
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone Number is required';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.visibility_off),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Submit Button
                ElevatedButton(
                  onPressed: (){
                    _submitForm(context);
                  },
                  child: Text('Submit'),
                ),
                SizedBox(height: 16),
                // Link to SignIn page
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignIn()), // Navigate to SignIn page
                    );
                  },
                  child: Text(
                    'Already have an account? Sign In',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
