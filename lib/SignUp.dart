import 'dart:convert'; // For Base64 encoding
import 'dart:io'; // For File operations
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Authentication.dart';
import 'package:image_picker/image_picker.dart';
import 'SignIn.dart';
import 'Base Classes/Friend.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Database.dart';

class Signup extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<Signup> {
  Databaseclass db = Databaseclass();
  AuthService auth = AuthService();
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

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String preferences = _preferencesController.text.trim();
      final String phoneNumber = _phoneNumberController.text.trim();
      final String password = _passwordController.text.trim();
      final File? image = _selectedImage;

      final imageBytes = await File(image!.path).readAsBytes();
      String encodedImage = base64Encode(imageBytes);

      if (await Friend.getUserByPhoneNumber(phoneNumber)) {
        showCustomSnackBar(context, "Phone number already registered");
      } else {
        // print(await db.insertData(
        //     "INSERT INTO Users (Name, Email, Preferences, PhoneNumber, Password, Image) VALUES ('$name', '$email', '$preferences', '$phoneNumber', '$password', '$encodedImage');"));

        auth.signUpWithEmailPassword(name, email, preferences, phoneNumber, password, encodedImage);

        showCustomSnackBar(context, "Account Registered Successfully!", backgroundColor: Colors.green);
        _nameController.clear();
        _emailController.clear();
        _preferencesController.clear();
        _phoneNumberController.clear();
        _passwordController.clear();
        image.delete();
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signup()));
      }
    }
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
              style: TextStyle(color: Colors.white, fontSize: 16),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Signup for Hedieaty App')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 100, // Adjust the size of the avatar
                  backgroundImage: AssetImage('Assets/logo.webp'), // Logo as background
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
              // Image Picker Section
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedImage == null ? "No image selected" : "Image selected",
                      style: TextStyle(
                        color: _selectedImage == null ? Colors.red : Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 40, // Adjust the size of the icon
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Submit Button
              // ElevatedButton(
              //   onPressed: () {
              //     _submitForm(context);
              //   },
              //   child: Text('Submit'),
              // ),
              ElevatedButton(
                onPressed:(){
                  _submitForm(context);

                } ,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[300],
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "SignUp",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Link to SignIn page
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => SignIn()),
                        (Route<dynamic> route) => false,
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
    );
  }

}
