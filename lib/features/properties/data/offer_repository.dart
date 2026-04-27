import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/features/properties/domain/offer_model.dart';
import 'package:uuid/uuid.dart';

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  return OfferRepository(FirebaseFirestore.instance);
});

final propertyOffersProvider = StreamProvider.family<List<OfferModel>, String>((ref, propertyId) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.streamOffersForProperty(propertyId);
});

final userOffersProvider = StreamProvider.family<List<OfferModel>, String>((ref, userId) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.streamOffersForUser(userId);
});

class OfferRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  OfferRepository(this._firestore);

  Future<void> submitOffer({
    required String propertyId,
    required String buyerId,
    required String ownerId,
    required double amount,
  }) async {
    try {
      final id = _uuid.v4();
      final offer = OfferModel(
        id: id,
        propertyId: propertyId,
        buyerId: buyerId,
        ownerId: ownerId,
        amount: amount,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('offers').doc(id).set(offer.toMap());
      LoggerService.i('Successfully submitted offer $id for property $propertyId');
    } catch (e, st) {
      LoggerService.e('Failed to submit offer', error: e, stack: st);
      rethrow;
    }
  }

  Stream<List<OfferModel>> streamOffersForProperty(String propertyId) {
    return _firestore
        .collection('offers')
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OfferModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<OfferModel>> streamOffersForUser(String userId) {
    // Note: Since Firestore doesn't support logical OR in simple queries across fields, 
    // we query where ownerId == userId. If we also want buyerId == userId, 
    // it's best to query both and merge or just query ownerId for now.
    // For simplicity, we query where ownerId or buyerId matches using Filter.or
    return _firestore
        .collection('offers')
        .where(Filter.or(
          Filter('ownerId', isEqualTo: userId),
          Filter('buyerId', isEqualTo: userId),
        ))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OfferModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateOfferStatus(String offerId, String status) async {
    try {
      await _firestore.collection('offers').doc(offerId).update({'status': status});
      LoggerService.i('Updated offer $offerId status to $status');
    } catch (e, st) {
      LoggerService.e('Failed to update offer status', error: e, stack: st);
      rethrow;
    }
  }
}
