import 'package:dio/dio.dart';

import '../components/service_request_provider.dart';

class SyncService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://your-api-server.com/api/',
    connectTimeout: Duration(milliseconds: 5000), // Convert int to Duration
    receiveTimeout: Duration(milliseconds: 3000), // Convert int to Duration
  ));

  // Sync local service requests with the server
  Future<void> syncServiceRequests(List<ServiceRequest> requests) async {
    try {
      for (var request in requests) {
        // Example endpoint for syncing service requests
        await _dio.post('/service_requests', data: request.toJson());
      }
    } catch (e) {
      print('Failed to sync service requests: $e');
    }
  }

  // Delete a service request on the server
  Future<void> deleteServiceRequest(int id) async {
    try {
      await _dio.delete('/service_requests/$id');
    } catch (e) {
      print('Failed to delete service request: $e');
    }
  }
}
