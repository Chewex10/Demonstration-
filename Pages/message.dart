import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class MessagePage extends StatefulWidget {
  final String recipientNumber;

  MessagePage({required this.recipientNumber}); // Receive recipient number

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  // Pre-configured messages
  final List<String> messages = [
    "On my way",
    "Service completed",
    "Issue encountered"
  ];

  // Initialize telephony instance
  final Telephony telephony = Telephony.instance;

  bool _isLoading = false; // State to manage loading indicator
  String? _selectedMessage; // State to manage selected message
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.recipientNumber; // Autofill with recipient's number
  }

  // Method to send SMS using telephony
  Future<void> _sendSMS(String message) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Request SMS permission
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      // Request permission if not granted
      await Permission.sms.request();
    }

    // Check again if permission is granted
    if (await Permission.sms.isGranted) {
      try {
        // Send SMS
        await telephony.sendSms(
          to: _phoneController.text,
          message: message,
        );

        setState(() {
          _isLoading = false; // Hide loading indicator
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Message sent successfully!"),
            backgroundColor: Colors.black87,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });

        // Handle any errors that may occur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send message: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      // Show message if permission is denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("SMS permission is required to send messages."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Send Message',
          style: TextStyle(
            color: Colors.white,
          ),

        ),

      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // TextFormField for phone number
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Recipient Phone Number',
                filled: true,
                fillColor: Color(0xFF2e2e2e),
                labelStyle: TextStyle(color: Color(0xFFf2f0f4)),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Color(0xFFf2f0f4)),
            ),
            SizedBox(height: 16),
            // Dropdown for message selection
            DropdownButtonFormField<String>(
              value: _selectedMessage,
              hint: Text('Select a message', style: TextStyle(color: Color(0xFFf2f0f4))),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFF2e2e2e),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.blue),
              items: messages.map((String message) {
                return DropdownMenuItem<String>(
                  value: message,
                  child: Text(message),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMessage = value;
                });
              },
            ),
            SizedBox(height: 16),
            // Send message button
            ElevatedButton(
              onPressed: _selectedMessage == null || _isLoading
                  ? null
                  : () {
                _sendSMS(_selectedMessage!); // Send the selected message
              },
              child: _isLoading
                  ? CircularProgressIndicator(
                color: Colors.white,
              )
                  : Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}
