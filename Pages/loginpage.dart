import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard.dart';
import 'mainpage.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onToggle; // Callback to toggle between login and register

  LoginPage({required this.onToggle}); // Accept the callback in the constructor

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Technician credentials
  final Map<String, String> technicianCredentials = {
    'electrical@example.com': 'electrical123', // Electrical technician
    'plumbing@example.com': 'plumbing123',     // Plumbing technician
    'itsupport@example.com': 'itsupport123'    // IT Support technician
  };


  bool _isLoading = false;

  // Define a variable to track valid email
  bool _isEmailValid = false;

  bool _isPasswordVisible = false;


  // Admin credentials
  final String adminEmail = 'admin@example.com'; // Set your admin email
  final String adminPassword = 'admin123'; // Set your admin password


  // Firebase Authentication
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        Fluttertoast.showToast(
          msg: "Login Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        // Check if the user is admin
        if (_emailController.text.trim() == adminEmail && _passwordController.text.trim() == adminPassword) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()), // Navigate to Dashboard for admin
          );
        }
        // After admin login check, add this section to check if the user is a technician.
        else if (technicianCredentials.containsKey(_emailController.text.trim()) &&
            technicianCredentials[_emailController.text.trim()] == _passwordController.text.trim()) {

          // Navigate to a Technician-specific page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()), // Replace with a technician-specific page if needed
          );

          Fluttertoast.showToast(
            msg: "Technician Login Successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
        else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()), // Navigate to MainPage for regular users
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        String message = '';
        if (e.code == 'user-not-found') {
          message = "No user found for that email.";
        } else if (e.code == 'wrong-password') {
          message = "Wrong password provided for that user.";
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
                  SizedBox(height: 70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 14.0, top: 80),
                        child: Text(
                          'Welcome back!',
                          style: TextStyle(
                            color: Color(0xFF575a89),
                            fontSize: 30,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,


                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 60),
                  SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(28.0),
                      width: MediaQuery.of(context).size.width, // Make the container full width
                      height: 472,
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
                        mainAxisSize: MainAxisSize.min,
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
                              suffixIcon: _isEmailValid // Conditionally show a checkmark
                                  ? Icon(Icons.check, color: Color(0xFF64c2c4))
                                  : null, // Show nothing when email is invalid
                            ),
                            style: TextStyle(
                              color: Color(0xFF575a89),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              setState(() {
                                // Check if the entered email is valid
                                _isEmailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return "Please enter a valid email address";
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 30),
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
                                borderRadius: BorderRadius.circular(10), // Optional: rounded corners
                              ),
                              contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10), // Padding: left, top, right, bottom
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off, // Change icon based on visibility
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible; // Toggle visibility state
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(
                              color: Color(0xFF575a89),
                            ),
                            obscureText: !_isPasswordVisible, // Set obscureText to the opposite of visibility state
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              } else if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Color(0xFF575a89),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 50),
                          _isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero, // Removes default padding to align with custom container style
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(34),
                              ),
                              elevation: 0, // Removes the elevation
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Color(0xFF64c2c4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                width: 300,
                                height: 48,
                                alignment: Alignment.center,
                                child: Text(
                                  'SIGN IN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    height: 1.0, // Adjusted for proper line height
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),
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
                                  'Sign up',
                                  style: TextStyle(
                                    color: Color(0xFF64c2c4),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 6),

                        ],
                      ),
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
