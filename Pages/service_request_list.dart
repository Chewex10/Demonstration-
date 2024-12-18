import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../components/service_request_provider.dart';
import 'ServiceRequestDetailPage.dart';

class ServiceRequestListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final approvedRequests = Provider.of<ServiceRequestProvider>(context).approvedRequests;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Approved Services",
          style: TextStyle(
            color: Color(0xFF64c2c4),
          ),
        ),
        automaticallyImplyLeading: false, // Prevent default back button
        leading: IconButton(
          icon: Image.asset(
            'lib/images/toolbox.png',
            height: 50,
            width: 50,
            color: Color(0xFF64c2c4),
          ), // Replace with your icon file
          onPressed: () {
            // Define the action for the button
            print('Icon button pressed');
          },
        ),
        elevation: 0, // Optional: remove the shadow for a cleaner look
      ),
      backgroundColor: Colors.grey.shade100,
      body: approvedRequests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib/images/empty.svg', // Add your empty state image here
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              'No completed requests available',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: 'inter',
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: approvedRequests.length,
        itemBuilder: (context, index) {
          final request = approvedRequests[index];
          return Card(
            margin: EdgeInsets.zero, // Remove margin around the card
            elevation: 0,
            color: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              // Set shape to a rectangle
              borderRadius: BorderRadius.zero, // Set radius to zero to remove rounding
            ),
            child: Stack(
              children: [
                ListTile(
                  title: Text(
                    request.clientName,
                    style: TextStyle(
                      color: Color(0xFF64c2c4),
                      fontFamily: 'inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.serviceDescription,
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'inter',
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                  leading: ClipRRect(
                    child: request.imagePath != null
                        ? Image.file(
                      File(request.imagePath!),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    )
                        : Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  onTap: () {
                    String recipientPhoneNumber = request.phoneNumber;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceRequestDetailPage(
                          index: index,
                          request: request,
                          recipientPhoneNumber: recipientPhoneNumber, // Pass the phone number
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 24,
                  right: 8,
                  child: Text(
                    request.status,
                    style: TextStyle(
                      color: Color(0xFF64c2c4),
                      fontFamily: 'Inter',
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
