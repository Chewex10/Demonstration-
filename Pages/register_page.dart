import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/sqaure_tile.dart';
import 'LoginPage.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onToggle; // Callback to toggle between login and register

  RegisterPage({required this.onToggle}); // Accept the callback in the constructor

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  // Firebase Authentication for Registration
  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        Fluttertoast.showToast(
          msg: "Registration Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        // Navigate to the LoginPage after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage(onToggle: () {})),
        );


      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        String message = '';
        if (e.code == 'email-already-in-use') {
          message = "The account already exists for that email.";
        } else if (e.code == 'weak-password') {
          message = "The password provided is too weak.";
        } else {
          message = "An error occurred: ${e.message}";
        }
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children:[ SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 110.0, top: 80),
                        child: Center(
                          child: Text(
                            'New account ',
                            style: TextStyle(
                              color: Color(0xFF575a89),
                              fontSize: 30,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 60),
                  Container(
                    padding: EdgeInsets.all(28.0),
                    width: MediaQuery.of(context).size.width, // Make the container full width
                    height: 572,
                    decoration: ShapeDecoration(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email", // The label moves to the top when focused
                            labelStyle: TextStyle(color: Color(0xFF575a89)), // Optional: style for the label
                            hintText: "Email", // Hint text when not focused
                            hintStyle: TextStyle(color: Color(0xFF575a89)), // Style for hint text
                            enabledBorder: OutlineInputBorder( // Pink border when not focused
                              borderSide: BorderSide(color: Color(0xFF64c2c4)),
                              borderRadius: BorderRadius.circular(1), // Optional: rounded corners
                            ),
                            focusedBorder: OutlineInputBorder( // Pink border when focused
                              borderSide: BorderSide(color: Color(0xFF64c2c4), width: 2),
                              borderRadius: BorderRadius.circular(12), // Optional: rounded corners
                            ),
                            contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10), // Padding: left, top, right, bottom
                          ),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20),
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: "Password", // The label moves to the top when focused
                            labelStyle: TextStyle(color: Color(0xFF575a89)), // Optional: style for the label
                            hintText: "Password", // Hint text when not focused
                            hintStyle: TextStyle(color: Color(0xFF575a89)), // Style for hint text
                            enabledBorder: OutlineInputBorder( // Pink border when not focused
                              borderSide: BorderSide(color: Color(0xFF64c2c4)),
                              borderRadius: BorderRadius.circular(1), // Optional: rounded corners
                            ),
                            focusedBorder: OutlineInputBorder( // Pink border when focused
                              borderSide: BorderSide(color: Color(0xFF64c2c4), width: 2),
                              borderRadius: BorderRadius.circular(12), // Optional: rounded corners
                            ),
                            contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10), // Padding: left, top, right, bottom
                          ),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          obscureText: true, // Keeps the password hidden
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password";
                            } else if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: "Confirm Password", // The label moves to the top when focused
                            labelStyle: TextStyle(color: Color(0xFF575a89)), // Optional: style for the label
                            hintText: "Confirm Password", // Hint text when not focused
                            hintStyle: TextStyle(color: Color(0xFF575a89)), // Style for hint text
                            enabledBorder: OutlineInputBorder( // Pink border when not focused
                              borderSide: BorderSide(color: Color(0xFF64c2c4)),
                              borderRadius: BorderRadius.circular(1), // Optional: rounded corners
                            ),
                            focusedBorder: OutlineInputBorder( // Pink border when focused
                              borderSide: BorderSide(color: Color(0xFF64c2c4), width: 2),
                              borderRadius: BorderRadius.circular(12), // Optional: rounded corners
                            ),
                            contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10), // Padding: left, top, right, bottom
                          ),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          obscureText: true, // Keeps the confirm password hidden
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please confirm your password";
                            } else if (value != _passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF64c2c4),
                            padding: EdgeInsets.zero, // Removes default padding to align with custom container style
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1),
                            ),
                            elevation: 0,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                            ),
                            child: Container(
                              width: 280,
                              height: 48,
                              alignment: Alignment.center,
                              child: Text(
                                'SIGN UP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  height: 1.0, // Adjusted for proper line height
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 80),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: TextStyle(
                                    color: Color(0xFF575a89),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                                SizedBox(width: 6),

                                GestureDetector(
                                  onTap: widget.onToggle, // Call the toggle function
                                  child: Text(
                                    'Sign in',
                                    style: TextStyle(
                                      color: Color(0xFF64c2c4),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],

                    ),
                  ),
                  // Email Field

                ],
              ),
            ),
          ),
         ]
        ),
      ),
    );
  }
}
