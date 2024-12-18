import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../components/service_request_provider.dart';
import 'ServiceRequestDetailPage.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadServiceRequests();
  }

  Future<void> _loadServiceRequests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final provider = Provider.of<ServiceRequestProvider>(context, listen: false);
      if (user.email == 'admin@example.com') {
        isAdmin = true;
        await provider.fetchAllServiceRequests();
      } else {
        isAdmin = false;
        // Fetch service requests for the logged-in user (client)
        await provider.fetchServiceRequestsByUser(user.email!);

        // Fetch service requests for the technician's category
        String category = _getUserCategory(user.email!);

        // Get the technician ID based on the category
        String technicianId = _getTechnicianIdByCategory(category);

        // Combine requests for the user and technician
        await provider.combineUserAndTechnicianRequests(user.email!, technicianId, category);
      }
      setState(() {}); // Refresh the UI
    }
  }

  // Method to get the technician ID based on the category
  String _getTechnicianIdByCategory(String category) {
    // Logic to return the technician ID based on the category
    // Replace this with your actual implementation
    // For example:
    if (category == 'Electrical') {
      return 'technician_electrical_id'; // Replace with actual technician ID
    } else if (category == 'Plumbing') {
      return 'technician_plumbing_id'; // Replace with actual technician ID
    } else if (category == 'IT Support') {
      return 'technician_it_support_id'; // Replace with actual technician ID
    }
    return ''; // Default or error case
  }


  String _getUserCategory(String email) {
    if (email.contains('electrical')) {
      return 'Electrical';
    } else if (email.contains('plumbing')) {
      return 'Plumbing';
    } else if (email.contains('it')) {
      return 'IT Support';
    }
    return 'General'; // Default category if none matches
  }

  @override
  Widget build(BuildContext context) {
    final serviceRequests = Provider.of<ServiceRequestProvider>(context).serviceRequests;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            "Dashboard",
            style: TextStyle(
              color: Color(0xFF64c2c4),
            ),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Image.asset(
              'lib/images/toolbox.png',
              height: 50,
              width: 50,
              color: Color(0xFF64c2c4),
            ),
            onPressed: () {
              print('Icon button pressed');
            },
          ),
          elevation: 0,
        ),
        backgroundColor: Colors.grey.shade100,
        body: serviceRequests.isEmpty
            ? Center(
          child: Text(
            'No requests available.',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
        )
            : ListView.builder(
          itemCount: serviceRequests.length,
          itemBuilder: (context, index) {
            final request = serviceRequests[index];

            return Dismissible(
              key: Key(request.clientName + index.toString()),
              background: isAdmin
                  ? Container(
                color: Colors.red,
                child: Icon(Icons.delete, color: Colors.white, size: 32),
              )
                  : Container(),
              secondaryBackground: isAdmin
                  ? Container(
                color: Colors.blue,
                child: Icon(Icons.edit, color: Colors.white, size: 32),
              )
                  : Container(),
              confirmDismiss: (direction) async {
                if (isAdmin) {
                  if (direction == DismissDirection.endToStart) {
                    _showEditDialog(context, index, request);
                    return false;
                  } else if (direction == DismissDirection.startToEnd) {
                    return await _confirmDelete(context, index);
                  }
                }
                return false;
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  margin: EdgeInsets.only(bottom: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Set the radius to 12
                  ),
                  elevation: 2,
                  color: Colors.grey.shade200,
                  child: Stack(
                    children: [
                      ListTile(
                        title: Text(
                          request.clientName,
                          style: TextStyle(color: Color(0xFF64c2c4), fontFamily: 'inter'),
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
                              : Icon(Icons.image, size: 50, color: Colors.white.withOpacity(0.6)),
                        ),
                        onTap: () {
                          String recipientPhoneNumber = request.phoneNumber;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceRequestDetailPage(
                                index: index,
                                request: request,
                                recipientPhoneNumber: recipientPhoneNumber,
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
                            color: Colors.black,
                            fontFamily: 'Inter',
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, int index) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this service request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ServiceRequestProvider>(context, listen: false).removeServiceRequest(index);
              Navigator.of(context).pop(true);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, int index, ServiceRequest request) {
    final _clientNameController = TextEditingController(text: request.clientName);
    final _serviceDescriptionController = TextEditingController(text: request.serviceDescription);
    String _status = request.status;
    String _category = request.category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Service Request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _clientNameController,
                decoration: InputDecoration(labelText: 'Client Name'),
              ),
              TextField(
                controller: _serviceDescriptionController,
                decoration: InputDecoration(labelText: 'Service Description'),
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Pending', 'In Progress', 'Completed']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  _status = value!;
                },
                decoration: InputDecoration(labelText: 'Status'),
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Electrical', 'Plumbing', 'IT Support']
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  _category = value!;
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final updatedRequest = request.copyWith(
                clientName: _clientNameController.text,
                serviceDescription: _serviceDescriptionController.text,
                status: _status,
                category: _category,
              );
              Provider.of<ServiceRequestProvider>(context, listen: false)
                  .updateServiceRequest(index, updatedRequest);
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
