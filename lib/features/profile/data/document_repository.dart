import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/document_model.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(FirebaseFirestore.instance, FirebaseStorage.instance);
});

final userDocumentsProvider = StreamProvider.family<List<DocumentModel>, String>((ref, userId) {
  return ref.watch(documentRepositoryProvider).streamUserDocuments(userId);
});

class DocumentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DocumentRepository(this._firestore, this._storage);

  Stream<List<DocumentModel>> streamUserDocuments(String userId) {
    return _firestore
        .collection('documents')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DocumentModel.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    });
  }

  Future<void> uploadDocument({
    required String userId,
    required File file,
    required String fileName,
    required String type,
  }) async {
    // 1. Upload to Storage
    final storageRef = _storage.ref().child('documents/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName');
    await storageRef.putFile(file);
    final url = await storageRef.getDownloadURL();

    // 2. Save to Firestore
    final doc = DocumentModel(
      id: '',
      userId: userId,
      name: fileName,
      url: url,
      type: type,
      uploadedAt: DateTime.now(),
    );

    await _firestore.collection('documents').add(doc.toMap());
  }

  Future<void> deleteDocument(String docId, String url) async {
    // 1. Delete from Firestore
    await _firestore.collection('documents').doc(docId).delete();
    
    // 2. Delete from Storage
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      // Handle or ignore if file already deleted from storage
    }
  }
}
