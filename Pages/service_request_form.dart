import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../components/service_request_provider.dart';

class ServiceRequestFormPage extends StatefulWidget {
  @override
  _ServiceRequestFormPageState createState() => _ServiceRequestFormPageState();
}

class _ServiceRequestFormPageState extends State<ServiceRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _clientName = '';
  String _email = '';
  String _phoneNumber = '';
  String _serviceDescription = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _location = 'Fetching location...';
  XFile? _image;
  String _selectedCategory = 'Electrical'; // Default category

  // Predefined categories
  final List<String> _categories = ['Electrical', 'Plumbing', 'IT Support'];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _locationData = await location.getLocation();
    if (!mounted) return;

    setState(() {
      _location = '${_locationData.latitude}, ${_locationData.longitude}';
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage = await picker.pickImage(source: ImageSource.camera);

    if (!mounted) return;

    setState(() {
      _image = selectedImage;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Determine the technicianId based on the selected category
      String technicianId;
      switch (_selectedCategory) {
        case 'Electrical':
          technicianId = 'your_electrical_technician_id';
          break;
        case 'Plumbing':
          technicianId = 'your_plumbing_technician_id';
          break;
        case 'IT Support':
          technicianId = 'your_it_support_technician_id';
          break;
        default:
          technicianId = 'default_technician_id';
      }

      final newRequest = ServiceRequest(
        userId: user.uid,
        clientName: _clientName,
        phoneNumber: _phoneNumber,
        email: _email,
        serviceDescription: _serviceDescription,
        date: "${_selectedDate.toLocal()}".split(' ')[0],
        time: _selectedTime,
        location: _location,
        imagePath: _image?.path,
        category: _selectedCategory,
        technicianId: technicianId,
      );

      Provider.of<ServiceRequestProvider>(context, listen: false)
          .addServiceRequest(newRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service Request Submitted')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF64c2c4),  // Updated color for the AppBar
        title: Text(
          'Service Request',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone, color: Color(0xFF64c2c4)),  // Updated color
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF64c2c4)),  // Updated color
                          ),
                        ),
                        onChanged: (value) => _phoneNumber = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Color(0xFF64c2c4)),  // Updated color
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF64c2c4)),  // Updated color
                          ),
                        ),
                        onChanged: (value) => _email = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Client Name',
                          prefixIcon: Icon(Icons.person, color: Color(0xFF64c2c4)),  // Updated color
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF64c2c4)),  // Updated color
                          ),
                        ),
                        onChanged: (value) => _clientName = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the client name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Service Description',
                          prefixIcon: Icon(Icons.description, color: Color(0xFF64c2c4)),  // Updated color
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF64c2c4)),  // Updated color
                          ),
                        ),
                        onChanged: (value) => _serviceDescription = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 4,
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Date: ${_selectedDate.toLocal()}".split(' ')[0]),
                      trailing: Icon(Icons.calendar_today, color: Color(0xFF64c2c4)),  // Updated color
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text("Time: ${_selectedTime.format(context)}"),
                      trailing: Icon(Icons.access_time, color: Color(0xFF64c2c4)),  // Updated color
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null && picked != _selectedTime) {
                          setState(() {
                            _selectedTime = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 4,
                child: ListTile(
                  title: Text('Location: $_location'),
                  trailing: Icon(Icons.location_on, color: Color(0xFF64c2c4)),  // Updated color
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category, color: Color(0xFF64c2c4)),  // Updated color
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF64c2c4)),  // Updated color
                      ),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    items: _categories
                        .map<DropdownMenuItem<String>>((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              _image == null
                  ? Text('No image selected.')
                  : Image.file(File(_image!.path)),
              FloatingActionButton(
                onPressed: _pickImage,
                child: Icon(Icons.camera_alt),
                backgroundColor: Color(0xFF64c2c4),  // Updated color for the Floating Action Button
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit Request'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF64c2c4),  // Updated color for the Elevated Button
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
