import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:servicefield/pages/welcome_page.dart';
import '../components/service_request_provider.dart';
import 'messagePage.dart'; // Import the MessagePage

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  String _defaultCategory = 'Electrical';
  bool _notificationsEnabled = true;
  String _language = 'English';
  String _userRole = 'User'; // Initial value, will change based on admin check
  String _permissions = 'Basic'; // Initial value, will change based on admin check

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // Check user role on init
  }

  // Mock technician credentials
  final Map<String, String> technicianCredentials = {
    'electrical@example.com': 'electrical123',
    'plumbing@example.com': 'plumbing123',
    'itsupport@example.com': 'itsupport123',
  };

  // Function to check if the current user is admin, technician, or user
  Future<void> _checkUserRole() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user.email == 'admin@example.com') {
        // If user is admin
        setState(() {
          _userRole = 'Admin';
          _permissions = 'Full Access';
        });
      } else if (technicianCredentials.containsKey(user.email)) {
        // If user is a technician
        setState(() {
          _userRole = 'Technician';
          _permissions = 'Technician Level Access';
        });
      } else {
        // If regular user
        setState(() {
          _userRole = 'User';
          _permissions = 'Basic';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final serviceRequestProvider = Provider.of<ServiceRequestProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF64c2c4),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Image.asset(
            'lib/images/toolbox.png',
            color: Color(0xFF64c2c4), // Tint color for the PNG
            height: 32, // Set the height of the icon
          ),
          onPressed: () {
            print('Icon button pressed');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFF64c2c4)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => WelcomePage()),
              );
            },
          ),
        ],
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Profile Section
            _buildUserProfileCard(user),

            SizedBox(height: 20),

            // Settings Section
            Expanded(
              child: ListView(
                children: [
                  _buildSettingsSectionCard(
                    title: 'General Settings',
                    content: Column(
                      children: [
                        _buildDropdownField(
                          label: 'Default Service Category',
                          value: _defaultCategory,
                          items: ['Electrical', 'Plumbing', 'Carpentry', 'Other'],
                          onChanged: (value) {
                            setState(() {
                              _defaultCategory = value!;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        SwitchListTile(
                          title: Text(
                            'Enable Notifications',
                            style: TextStyle(color: Color(0xFF64c2c4)),
                          ),
                          value: _notificationsEnabled,
                          activeColor: Color(0xFF64c2c4),
                          onChanged: (bool value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildSettingsSectionCard(
                    title: 'Language Preferences',
                    content: _buildDropdownField(
                      label: 'Language',
                      value: _language,
                      items: ['English', 'Spanish', 'French', 'German'],
                      onChanged: (value) {
                        setState(() {
                          _language = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildSettingsSectionCard(
                    title: 'Account Information',
                    content: Column(
                      children: [
                        _buildReadOnlyField(
                          label: 'User Role',
                          value: _userRole,
                        ),
                        SizedBox(height: 10),
                        _buildReadOnlyField(
                          label: 'Permissions',
                          value: _permissions,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // User profile section with avatar and email display
  Widget _buildUserProfileCard(User? user) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2)],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 3,
              backgroundImage: AssetImage('lib/images/user.png'),
              backgroundColor: Colors.transparent,
            ),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.email ?? 'Guest User',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64c2c4),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Edit your profile',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Settings section card
  Widget _buildSettingsSectionCard({required String title, required Widget content}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64c2c4),
            ),
          ),
          SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  // Dropdown field for selecting options
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF64c2c4)),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF64c2c4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF64c2c4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF64c2c4)),
        ),
      ),
      dropdownColor: Colors.white,
      iconEnabledColor: Color(0xFF64c2c4),
      onChanged: onChanged,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: Color(0xFF64c2c4))),
        );
      }).toList(),
    );
  }

  // Read-only field for displaying user info
  Widget _buildReadOnlyField({required String label, required String value}) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF64c2c4)),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF64c2c4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF64c2c4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF64c2c4)),
        ),
      ),
      readOnly: true,
      style: TextStyle(color: Colors.black),
    );
  }
}
