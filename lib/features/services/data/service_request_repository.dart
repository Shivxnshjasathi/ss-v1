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

final streamRequestByIdProvider = StreamProvider.family<ServiceRequestModel?, String>((ref, id) {
  LoggerService.i('ServiceStream: Listening to request $id');
  return ref.watch(serviceRequestRepositoryProvider).streamRequestById(id);
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

final moversLeadsProvider = StreamProvider<List<ServiceRequestModel>>((ref) {
  LoggerService.i('ServiceStream: Listening to Movers leads');
  return ref.watch(serviceRequestRepositoryProvider).streamRequestsByCategory('Movers');
});

final allSiteVisitsStreamProvider = StreamProvider<List<ServiceRequestModel>>((ref) {
  LoggerService.i('ServiceStream: Listening to ALL site visits');
  return ref.watch(serviceRequestRepositoryProvider).streamAllSiteVisits();
});

final cityVisitorRequestsStreamProvider = StreamProvider.family<List<ServiceRequestModel>, String>((ref, city) {
  LoggerService.i('ServiceStream: Listening to site visits in $city');
  return ref.watch(serviceRequestRepositoryProvider).streamSiteVisitsByCity(city);
});

final userServiceRequestsProvider = StreamProvider.family<List<ServiceRequestModel>, String>((ref, userId) {
  LoggerService.i('ServiceStream: Listening to user service requests for $userId');
  return ref.watch(serviceRequestRepositoryProvider).streamUserRequests(userId);
});

final userAllServicesProvider = StreamProvider.family<List<ServiceRequestModel>, ({String userId, String? email})>((ref, arg) {
  LoggerService.i('ServiceStream: Listening to all services for user ${arg.userId} / ${arg.email}');
  return ref.watch(serviceRequestRepositoryProvider).streamUserAndTenantRequests(arg.userId, arg.email);
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

  Future<ServiceRequestModel?> getRequestById(String id) async {
    LoggerService.i('Service: Fetching request $id');
    try {
      final doc = await _firestore.collection('service_requests').doc(id).get();
      if (!doc.exists) return null;
      return ServiceRequestModel.fromMap(doc.data()!, doc.id);
    } catch (e, st) {
      LoggerService.e('Service: Failed to fetch request $id', error: e, stack: st);
      return null;
    }
  }

  Stream<ServiceRequestModel?> streamRequestById(String id) {
    return _firestore.collection('service_requests').doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ServiceRequestModel.fromMap(doc.data()!, doc.id);
    });
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

  Future<void> updateRequestDetails(String requestId, Map<String, dynamic> newDetails) async {
    LoggerService.i('Service: Updating details for request $requestId');
    try {
      await _firestore.collection('service_requests').doc(requestId).update({'details': newDetails});
      LoggerService.i('Service: Successfully updated details for $requestId');
    } catch (e, st) {
      LoggerService.e('Service: Failed to update details for $requestId', error: e, stack: st);
      rethrow;
    }
  }

  Stream<List<ServiceRequestModel>> streamUserRequests(String userId) {
    return _firestore
        .collection('service_requests')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => ServiceRequestModel.fromMap(doc.data(), doc.id))
              .toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
  }

  Stream<List<ServiceRequestModel>> streamUserAndTenantRequests(String userId, String? email) {
    Query query = _firestore.collection('service_requests');
    
    if (email != null && email.isNotEmpty) {
      query = query.where(
        Filter.or(
          Filter('userId', isEqualTo: userId),
          Filter('tenantEmail', isEqualTo: email),
        ),
      );
    } else {
      query = query.where('userId', isEqualTo: userId);
    }

    return query.snapshots().map((snapshot) {
      final docs = snapshot.docs
          .map((doc) => ServiceRequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    });
  }
}
