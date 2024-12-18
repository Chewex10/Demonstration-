import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servicefield/pages/welcome_page.dart';
import 'LoginPage.dart';
import 'login_or_register_page.dart';
import 'mainpage.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is logged in
        if (snapshot.hasData) {
          return MainPage(); // Navigate to MainPage if user is logged in
        } else {
          // User is NOT logged in
          return WelcomePage(); // Navigate to LoginPage if user is not logged in
        }
      },
    );
  }
}
