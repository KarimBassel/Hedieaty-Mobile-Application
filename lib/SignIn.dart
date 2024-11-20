import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Database.dart';
import 'package:hedieatymobileapplication/Base%20Classes/Friend.dart';
import 'package:hedieatymobileapplication/Home.dart';
import 'package:image_picker/image_picker.dart';
import 'signup.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn>{
  final Databaseclass db = Databaseclass();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitForm() async{
    if (_formKey.currentState!.validate()) {
      final String phoneNumber = _phoneNumberController.text.trim();
      final String password = _passwordController.text.trim();

      //List<Map<String,dynamic>> response =  db.readData("SELECT * FROM Users WHERE PhoneNumber='${phoneNumber}' and Password='${password}'");
      Friend user = await Friend.getuser(phoneNumber, password);
      if(user!=null){
        List<Friend> friendlist = await Friend.getFriends(user.id);
        user.friendlist = friendlist;
        print(user.id);
        Navigator.push(context,MaterialPageRoute(builder: (context)=> Home(User:user)));
      }

    }
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
                  onPressed: _submitForm,
                  child: Text('Sign In'),
                ),
                SizedBox(height: 16),
                // Link to SignUp page
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Signup()), // Navigate to SignUp page
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
