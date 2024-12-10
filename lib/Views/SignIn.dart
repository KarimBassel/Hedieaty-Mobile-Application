import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Controllers/FriendController.dart';
import 'package:hedieatymobileapplication/FirebaseMessaging.dart';
import 'package:hedieatymobileapplication/Models/Database.dart';
import 'package:hedieatymobileapplication/Models/Event.dart';
import 'package:hedieatymobileapplication/Models/Friend.dart';
import 'package:hedieatymobileapplication/Views/Home.dart';
import 'package:image_picker/image_picker.dart';
import '../Models/Authentication.dart';
import 'signup.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn>{
  final FriendController contoller = FriendController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _EmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Sign In for Hedieaty App')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 100, // Adjust the size of the avatar
                    backgroundImage: AssetImage('Assets/logo.webp'), // Logo as background
                  ),
                ),
                SizedBox(height: 16),
                // Phone Number Field
                TextFormField(
                  controller: _EmailController,
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
                SizedBox(height: 20),
                // Submit Button
                // ElevatedButton(
                //   onPressed: _submitForm,
                //   child: Text('Sign In'),
                // ),
          ElevatedButton(
            onPressed: ()async{
              await contoller.SubmitSignInForm(_EmailController, _passwordController, _formKey, context);

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[300],
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
            ),
            child: Text(
              "SignIn",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

                SizedBox(height: 16),
                // Link to SignUp page
                TextButton(
                  onPressed: () {
                    contoller.NavigatetoSignUp(context);
                  },
                  child: Text(
                    'Don\'t have an account? Sign Up',
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
