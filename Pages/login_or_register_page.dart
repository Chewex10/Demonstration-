import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  @override
  _LoginOrRegisterPageState createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  // Track whether to show login or register page
  bool _showLoginPage = true;

  // Toggle between login and register pages
  void _togglePages() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _showLoginPage
          ? LoginPage(onToggle: _togglePages) // Pass toggle function to LoginPage
          : RegisterPage(onToggle: _togglePages), // Pass toggle function to RegisterPage
    );
  }
}
