import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/service_request_provider.dart';
import 'local_database.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // Sync local database service requests to Firestore
  Future<void> syncLocalToFirestore() async {
    final localDatabase = LocalDatabase.instance;

    // Fetch all service requests from the local database
    List<ServiceRequest> localServiceRequests = await localDatabase.readAllServiceRequestsForAdmin();

    // Sync each local service request to Firestore
    for (var request in localServiceRequests) {
      await _db.collection('serviceRequests').doc(request.id.toString()).set(request.toJson());
    }
  }

  // Sync Firestore service requests to the local database
  Future<void> syncFirestoreToLocal() async {
    final localDatabase = LocalDatabase.instance;

    // Fetch all service requests from Firestore
    final snapshot = await _db.collection('serviceRequests').get();
    List<ServiceRequest> firestoreServiceRequests = snapshot.docs
        .map((doc) => ServiceRequest.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Insert or update each Firestore service request in the local database
    for (var request in firestoreServiceRequests) {
      // Make sure to merge changes rather than overwrite blindly
      await localDatabase.insertOrUpdate(request);
    }
  }

  // Ensure that new service requests are both added to Firestore and local DB
  Future<void> addServiceRequest(ServiceRequest request) async {
    final localDatabase = LocalDatabase.instance;

    // Generate a unique ID for the service request if it doesn't have one
    if (request.id == null) {
      request.id = _uuid.v4(); // Generate a unique ID using uuid
    }

    try {
      // Use the generated ID to set the Firestore document ID
      await _db.collection('serviceRequests').doc(request.id.toString()).set(request.toJson());

      // After successful Firestore write, insert into local database
      await localDatabase.insertOrUpdate(request);
    } catch (e) {
      print("Error adding service request: $e");
    }
  }

  // Update Firestore and local database service request
  Future<void> updateServiceRequest(ServiceRequest request) async {
    final localDatabase = LocalDatabase.instance;

    // Ensure the request has an ID
    if (request.id != null) {
      try {
        await _db.collection('serviceRequests').doc(request.id.toString()).update(request.toJson());

        // Also update the local database after Firestore update
        await localDatabase.insertOrUpdate(request);
      } catch (e) {
        print("Error updating service request: $e");
      }
    } else {
      print('Error: Service request ID is null.');
    }
  }

  // Updated deleteServiceRequest method to delete from both Firestore and local database
  // Updated deleteServiceRequest method to delete from both Firestore and local database
  Future<void> deleteServiceRequest(String id) async {
    final localDatabase = LocalDatabase.instance;

    try {
      // Delete from Firestore
      await _db.collection('serviceRequests').doc(id).delete();

      // Also remove from local database using the correct method name
      await localDatabase.delete(id);
    } catch (e) {
      print("Error deleting service request: $e");
    }
  }


  // Sync service requests list to Firestore
  Future<void> syncServiceRequests(List<ServiceRequest> serviceRequests) async {
    for (var request in serviceRequests) {
      await _db.collection('serviceRequests').doc(request.id.toString()).set(request.toJson());
    }
  }

  // Fetch service requests for a user
  Future<List<ServiceRequest>> fetchServiceRequests(String userId) async {
    final snapshot = await _db.collection('serviceRequests')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => ServiceRequest.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  // Fetch service requests for admin
  Future<List<ServiceRequest>> fetchServiceRequestsForAdmin() async {
    final snapshot = await _db.collection('serviceRequests').get();
    return snapshot.docs.map((doc) => ServiceRequest.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  // Fetch service requests by category
  Future<List<ServiceRequest>> fetchServiceRequestsByCategory(String category) async {
    final snapshot = await _db.collection('serviceRequests')
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs.map((doc) => ServiceRequest.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  // Fetch service requests by user email
  Future<List<ServiceRequest>> fetchServiceRequestsByUser(String email) async {
    final snapshot = await _db.collection('serviceRequests')
        .where('email', isEqualTo: email) // Query by email
        .get();
    return snapshot.docs.map((doc) => ServiceRequest.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }
}
