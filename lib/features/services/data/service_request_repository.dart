import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import '../domain/service_request_model.dart';

final serviceRequestRepositoryProvider = Provider<ServiceRequestRepository>((ref) {
  return ServiceRequestRepository(FirebaseFirestore.instance);
});

final providerRequestsStreamProvider = StreamProvider.family<List<ServiceRequestModel>, String>((ref, category) {
  LoggerService.i('ServiceStream: Listening to $category requests');
  return ref.watch(serviceRequestRepositoryProvider).streamRequestsByCategory(category);
});

final constructionLeadsProvider = StreamProvider<List<ServiceRequestModel>>((ref) {
  LoggerService.i('ServiceStream: Listening to Construction leads');
  const categories = ['Construction', 'Architecture', 'Interiors', 'Consultation', 'Borewell'];
  return ref.watch(serviceRequestRepositoryProvider).streamRequestsByCategories(categories);
});

final legalLeadsProvider = StreamProvider<List<ServiceRequestModel>>((ref) {
  LoggerService.i('ServiceStream: Listening to Legal leads');
  const categories = ['Legal', 'Property Verification'];
  return ref.watch(serviceRequestRepositoryProvider).streamRequestsByCategories(categories);
});

final allSiteVisitsStreamProvider = StreamProvider<List<ServiceRequestModel>>((ref) {
  LoggerService.i('ServiceStream: Listening to ALL site visits');
  return ref.watch(serviceRequestRepositoryProvider).streamAllSiteVisits();
});

final cityVisitorRequestsStreamProvider = StreamProvider.family<List<ServiceRequestModel>, String>((ref, city) {
  LoggerService.i('ServiceStream: Listening to site visits in $city');
  return ref.watch(serviceRequestRepositoryProvider).streamSiteVisitsByCity(city);
});

class ServiceRequestRepository {
  final FirebaseFirestore _firestore;

  ServiceRequestRepository(this._firestore);

  Future<void> addRequest(ServiceRequestModel request) async {
    LoggerService.i('Service: Adding new request ${request.id} for ${request.category}');
    try {
      await _firestore.collection('service_requests').doc(request.id).set(request.toMap());
      LoggerService.i('Service: Successfully added request ${request.id}');
    } catch (e, st) {
      LoggerService.e('Service: Failed to add request ${request.id}', error: e, stack: st);
      rethrow;
    }
  }

  Stream<List<ServiceRequestModel>> streamRequestsByCategory(String category) {
    return _firestore
        .collection('service_requests')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => ServiceRequestModel.fromMap(doc.data(), doc.id))
              .toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
  }

  Stream<List<ServiceRequestModel>> streamRequestsByCategories(List<String> categories) {
    if (categories.isEmpty) return Stream.value([]);
    return _firestore
        .collection('service_requests')
        .where('category', whereIn: categories)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => ServiceRequestModel.fromMap(doc.data(), doc.id))
              .toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
  }

  Stream<List<ServiceRequestModel>> streamAllSiteVisits() {
    return _firestore
        .collection('service_requests')
        .where('category', isEqualTo: 'SiteVisit')
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
            .map((doc) => ServiceRequestModel.fromMap(doc.data(), doc.id))
            .toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
  }

  Stream<List<ServiceRequestModel>> streamSiteVisitsByCity(String city) {
    return _firestore
        .collection('service_requests')
        .where('category', isEqualTo: 'SiteVisit')
        .where('location', isEqualTo: city)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
            .map((doc) => ServiceRequestModel.fromMap(doc.data(), doc.id))
            .toList();
          // Sort in memory
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    LoggerService.i('Service: Updating request $requestId status to $status');
    try {
      await _firestore.collection('service_requests').doc(requestId).update({'status': status});
      LoggerService.i('Service: Successfully updated status for $requestId');
    } catch (e, st) {
      LoggerService.e('Service: Failed to update status for $requestId', error: e, stack: st);
      rethrow;
    }
  }
}
