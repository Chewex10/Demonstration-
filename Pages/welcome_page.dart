
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


import 'login_or_register_page.dart';


class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                'FIELD SERVICE HUB',
                style: TextStyle(
                  color: Color(0xFF64c2c4),
                  fontSize: 32,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),

              Text(
                'Service that exceeds expectations',
                style: TextStyle(
                  color: Color(0xFF8ca7a8),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),

              Container(
                child: Image.asset(
                  'lib/images/wel.png',
                  width: 300,
                  height: 300,

                ),
              ),


              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // To space them evenly
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginOrRegisterPage()), // Replace with your actual LoginPage class
                      );
                    },
                    child: Container(
                      width: 150, // Adjust the width as needed
                      height: 48,
                      decoration: ShapeDecoration(
                        color: Color(0xFF64c2c4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            height: 1.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginOrRegisterPage()), // Replace with your actual LoginPage class
                      );
                    },
                    child: Container(
                      width: 150, // Adjust the width as needed
                      height: 48,
                      decoration: ShapeDecoration(
                        color: Color(0xFF64c2c4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            height: 1.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
