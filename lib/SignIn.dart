import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Database.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Event.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Friend.dart';
import 'package:hedieatymobileapplication/Home.dart';
import 'package:image_picker/image_picker.dart';
import 'Base Classes/Authentication.dart';
import 'signup.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn>{
  final Databaseclass db = Databaseclass();
  AuthService auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _EmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitForm() async{
    if (_formKey.currentState!.validate()) {
      final String Email = _EmailController.text.trim();
      final String password = _passwordController.text.trim();

      //List<Map<String,dynamic>> response =  db.readData("SELECT * FROM Users WHERE PhoneNumber='${phoneNumber}' and Password='${password}'");
      // dynamic user = await Friend.getUser(Email, password);
      // if(user is bool){
      //   showCustomSnackBar(context, "Incorrect Phone or Password");
      // }
      // else{
      //   // List<Friend> friendlist = await Friend.getFriends(user.id);
      //   // user.friendlist = friendlist;
      //   // List<Event> eventlist = await Friend.getEvents(user.id);
      //   // user.eventlist = eventlist;
      //   user = await Friend.getUserObject(user.id);
      //   print(user.id);
      //   Navigator.push(context,MaterialPageRoute(builder: (context)=> Home(User:user)));
      // }

      dynamic user = await auth.signInWithEmailAndPassword(Email, password);
      if(user==null){
        showCustomSnackBar(context, "Incorrect Email or Password");
      }
      else{
        Friend authenticateduser = await Friend.getUserObject(user);
        print(user);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Home(User:authenticateduser)),
              (Route<dynamic> route) => false,
        );
        //Navigator.push(context,MaterialPageRoute(builder: (context)=> Home(User:authenticateduser)));
      }

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
            onPressed: _submitForm,
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
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Signup()),
                          (Route<dynamic> route) => false,
                    );
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
