import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/marketplace_item_model.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepository(FirebaseFirestore.instance);
});

final allMarketplaceItemsProvider = StreamProvider<List<MarketplaceItemModel>>((ref) {
  return ref.watch(marketplaceRepositoryProvider).streamAllItems();
});

final vendorMarketplaceItemsProvider = StreamProvider.family<List<MarketplaceItemModel>, String>((ref, vendorId) {
  return ref.watch(marketplaceRepositoryProvider).streamVendorItems(vendorId);
});

class MarketplaceRepository {
  final FirebaseFirestore _firestore;

  MarketplaceRepository(this._firestore);

  Future<void> addItem(MarketplaceItemModel item) async {
    await _firestore.collection('marketplace_items').doc(item.id).set(item.toMap());
  }

  Future<void> deleteItem(String itemId) async {
    await _firestore.collection('marketplace_items').doc(itemId).delete();
  }

  Stream<List<MarketplaceItemModel>> streamAllItems() {
    return _firestore
        .collection('marketplace_items')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MarketplaceItemModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<List<MarketplaceItemModel>> streamVendorItems(String vendorId) {
    return _firestore
        .collection('marketplace_items')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => MarketplaceItemModel.fromMap(doc.data(), doc.id))
              .toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
  }

  Future<void> updateItemStatus(String itemId, String status) async {
    await _firestore.collection('marketplace_items').doc(itemId).update({'status': status});
  }
}
