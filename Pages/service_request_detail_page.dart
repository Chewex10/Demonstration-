import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';  // Import url_launcher package
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth to check user email
import 'package:servicefield/pages/messagePage.dart';
import '../components/service_request_provider.dart';
import '../utils/report_generator.dart';

class ServiceRequestDetailPage extends StatelessWidget {
  final int index;
  final ServiceRequest request;
  final String recipientPhoneNumber;

  ServiceRequestDetailPage({
    required this.index,
    required this.request,
    required this.recipientPhoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    bool isCompleted = request.status == 'Completed';
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    final String? userEmail = user?.email; // Get the email of the logged-in user

    // Define the condition for displaying the Approve and Message buttons
    bool isAdminOrTechnician = userEmail == 'admin@example.com' || _isTechnician(userEmail);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF64c2c4), // Updated color
        elevation: 2,
        title: Text(
          "Service Request Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white), // Share icon
            onPressed: () {
              final generator = ReportGenerator();
              generator.generateAndShareReport(request);
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFf2f0f4),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard('Phone Number:', request.phoneNumber),
              SizedBox(height: 10),
              _buildInfoCard('Email:', request.email),
              SizedBox(height: 10),
              _buildInfoCard('Client Name:', request.clientName),
              SizedBox(height: 10),
              _buildInfoCard('Service Description:', request.serviceDescription),
              SizedBox(height: 10),
              _buildInfoCard('Date:', request.date),
              SizedBox(height: 10),
              _buildInfoCard('Time:', request.time.format(context)),
              SizedBox(height: 10),
              // Location card with tap event to open Google Maps
              GestureDetector(
                onTap: () {
                  _openGoogleMaps(request.location);
                },
                child: _buildInfoCard('Location:', request.location),
              ),
              SizedBox(height: 10),
              _buildInfoCard('Category:', request.category),
              SizedBox(height: 10),

              // Image Display
              request.imagePath != null
                  ? Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(request.imagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
                  : Center(child: Icon(Icons.image, size: 60, color: Color(0xFF64c2c4))), // Changed color

              SizedBox(height: 20),

              // Show the Approve and Message buttons only if the user is admin or technician
              if (isAdminOrTechnician)
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        isCompleted ? 'Completed' : 'Approve',
                        isCompleted
                            ? null
                            : () {
                          Provider.of<ServiceRequestProvider>(context, listen: false).approveServiceRequest(index);
                          Navigator.pop(context);
                        },
                        Colors.white,
                        Color(0xFF64c2c4), // Color for Approve button
                      ),
                    ),
                    SizedBox(width: 10), // Space between buttons
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Message',
                            () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MessagePage(recipientNumber: recipientPhoneNumber),
                          ));
                        },
                        Colors.white,
                        Color(0xFFf59e42), // Different color for Message button
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

  Widget _buildInfoCard(String title, String content) {
    return Container(
      padding: EdgeInsets.all(18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF64c2c4)), // Changed color
          ),
          SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, VoidCallback? onPressed, Color textColor, Color bgColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
        style: ElevatedButton.styleFrom(
          primary: bgColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // Function to open Google Maps with the provided location
  Future<void> _openGoogleMaps(String location) async {
    final String encodedLocation = Uri.encodeComponent(location);
    final Uri geoUrl = Uri.parse('geo:0,0?q=$encodedLocation'); // Use geo: scheme for better compatibility
    if (await canLaunch(geoUrl.toString())) {  // Use canLaunch
      await launch(geoUrl.toString());  // Use launch
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  // Helper function to check if the email belongs to a technician
  bool _isTechnician(String? email) {
    // Add the logic to check if the email belongs to a technician
    const List<String> technicianEmails = ['electrical@example.com', 'plumbing@example.com', 'itsupport@example.com'];
    return technicianEmails.contains(email);
  }
}
