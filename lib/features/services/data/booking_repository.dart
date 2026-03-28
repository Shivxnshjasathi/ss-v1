import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/booking_model.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(FirebaseFirestore.instance);
});

final userBookingsProvider = StreamProvider.family<List<BookingModel>, String>((ref, userId) {
  return ref.watch(bookingRepositoryProvider).streamUserBookings(userId);
});

final ownerBookingsProvider = StreamProvider.family<List<BookingModel>, String>((ref, ownerId) {
  return ref.watch(bookingRepositoryProvider).streamOwnerBookings(ownerId);
});

class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository(this._firestore);

  Future<void> addBooking(BookingModel booking) async {
    await _firestore.collection('bookings').doc(booking.id).set(booking.toMap());
  }

  Stream<List<BookingModel>> streamUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('buyerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList();
          // Sort in memory to avoid needing a composite index
          docs.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
          return docs;
        });
  }

  Stream<List<BookingModel>> streamOwnerBookings(String ownerId) {
    return _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList();
          // Sort in memory to avoid needing a composite index
          docs.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
          return docs;
        });
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({'status': status});
  }
}
