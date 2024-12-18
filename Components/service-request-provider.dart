import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../utils/firestore_service.dart';
import '../utils/local_database.dart';

class ServiceRequest {
  String? id;
  final String userId;
  final String clientName;
  final String phoneNumber;
  final String email;
  final String serviceDescription;
  final String date;
  final TimeOfDay time;
  final String location;
  final String? imagePath;
  final bool isApproved;
  final String status;
  final String category;
  final String technicianId;

  ServiceRequest({
    this.id,
    required this.userId,
    required this.clientName,
    required this.phoneNumber,
    required this.email,
    required this.serviceDescription,
    required this.date,
    required this.time,
    required this.location,
    this.imagePath,
    this.isApproved = false,
    this.status = 'Pending',
    required this.category,
    required this.technicianId,
  });

  ServiceRequest copyWith({
    String? id,
    String? userId,
    String? clientName,
    String? email, // Add it here
    String? serviceDescription,
    String? date,
    TimeOfDay? time,
    String? location,
    String? imagePath,
    bool? isApproved,
    String? status,
    String? category,
    String? technicianId,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientName: clientName ?? this.clientName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      isApproved: isApproved ?? this.isApproved,
      status: status ?? this.status,
      category: category ?? this.category,
      technicianId: technicianId ?? this.technicianId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'clientName': clientName,
      'phoneNumber': phoneNumber,
      'email': email,
      'serviceDescription': serviceDescription,
      'date': date,
      'time': '${time.hour}:${time.minute}',
      'location': location,
      'imagePath': imagePath,
      'isApproved': isApproved ? 1 : 0,
      'status': status,
      'category': category,
      'technicianId': technicianId,
    };
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String?,
      userId: json['userId'] ?? '',
      clientName: json['clientName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      serviceDescription: json['serviceDescription'] ?? '',
      date: json['date'] ?? '',
      time: _parseTimeOfDay(json['time'] ?? '00:00'),
      location: json['location'] ?? '',
      imagePath: json['imagePath'],
      isApproved: (json['isApproved'] ?? 0) == 1,
      status: json['status'] ?? 'Pending',
      category: json['category'] ?? '',
      technicianId: json['technicianId'] ?? '',
    );
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }
}

class ServiceRequestProvider with ChangeNotifier {
  List<ServiceRequest> _serviceRequests = [];
  String _userId = '';
  final FirestoreService _firestoreService = FirestoreService();
  final SyncService _syncService = SyncService();

  /// Combines service requests for a specific user and technician based on category.
  Future<void> combineUserAndTechnicianRequests(String userEmail, String technicianId, String category) async {
    try {
      // Fetch service requests for the user
      final userRequests = await _firestoreService.fetchServiceRequestsByUser(userEmail);
      // Fetch service requests for the technician based on category
      final technicianRequests = await _firestoreService.fetchServiceRequestsByCategory(category);

      // Combine the results
      _serviceRequests = [...userRequests, ...technicianRequests];

      // Sync with local database
      await LocalDatabase.instance.syncServiceRequests(_serviceRequests);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch combined service requests: $e');
    }
  }



  Future<String?> fetchRecipientEmail(String serviceRequestId) async {
    try {
      // Ensure that _serviceRequests is accessible
      final serviceRequest = _serviceRequests.firstWhere(
            (request) => request.id == serviceRequestId,
        orElse: () => throw Exception("Service Request not found"),
      );

      // Return the correct email field
      return serviceRequest.email;
    } catch (e) {
      print('Failed to fetch recipient email: $e');
      return null;
    }
  }


  Future<void> sendEmailWithServiceRequest(String serviceRequestId, String message) async {
    final recipientEmail = await fetchRecipientEmail(serviceRequestId);

    if (recipientEmail != null) {

    } else {
      print('No recipient email found for service request $serviceRequestId');
    }
  }

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  Future<void> fetchServiceRequests(String userId) async {
    try {
      final requests = await _firestoreService.fetchServiceRequests(userId);
      _serviceRequests = requests;
      await LocalDatabase.instance.syncServiceRequests(requests);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch service requests: $e');
    }
  }

  Future<void> fetchAllServiceRequests() async {
    try {
      final requests = await _firestoreService.fetchServiceRequestsForAdmin();
      _serviceRequests = requests;
      await LocalDatabase.instance.syncServiceRequests(requests);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch all service requests: $e');
    }
  }


  Future<void> fetchServiceRequestsByCategory(String category) async {
    try {
      final requests = await _firestoreService.fetchServiceRequestsByCategory(category);
      _serviceRequests = requests;
      await LocalDatabase.instance.syncServiceRequests(requests);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch service requests by category: $e');
    }
  }

  Future<void> fetchServiceRequestsByUser(String userEmail) async {
    try {
      final requests = await _firestoreService.fetchServiceRequestsByUser(userEmail);
      _serviceRequests = requests;
      await LocalDatabase.instance.syncServiceRequests(requests);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch service requests by user: $e');
    }
  }

  List<ServiceRequest> get serviceRequests => _serviceRequests;

  List<ServiceRequest> get approvedRequests =>
      _serviceRequests.where((request) => request.status == 'Completed').toList();

  Future<void> loadRequests() async {
    if (_userId.isNotEmpty) {
      _serviceRequests =
      await LocalDatabase.instance.readAllServiceRequests(_userId);
      notifyListeners();
    }
  }

  Future<void> addServiceRequest(ServiceRequest request) async {

    await _firestoreService.addServiceRequest(request);


    _serviceRequests.add(request);


    notifyListeners();
  }


  Future<void> removeServiceRequest(int index) async {
    final request = _serviceRequests[index];
    try {
      if (request.id != null) {
        await _firestoreService.deleteServiceRequest(request.id!);
        await LocalDatabase.instance.delete(request.id!);
        _serviceRequests.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      print('Failed to delete service request: $e');
    }
  }

  Future<void> updateServiceRequest(int index, ServiceRequest updatedRequest) async {
    try {
      await _firestoreService.updateServiceRequest(updatedRequest);
      _serviceRequests[index] = updatedRequest;
      notifyListeners();
    } catch (e) {
      print('Failed to update service request: $e');
    }
  }

  Future<void> approveServiceRequest(int index) async {
    // Create a copy with the updated approval status
    final updatedRequest = _serviceRequests[index].copyWith(
      isApproved: true,
      status: 'Completed',
    );

    // Await the update to ensure UI is refreshed
    await updateServiceRequest(index, updatedRequest);
  }

  // New method to fetch requests for a specific technician
  List<ServiceRequest> getRequestsForTechnician(String technicianId) {
    return _serviceRequests.where((request) => request.technicianId == technicianId).toList();
  }
}
