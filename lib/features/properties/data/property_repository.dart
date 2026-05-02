import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import '../domain/property_model.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return PropertyRepository(FirebaseFirestore.instance, FirebaseStorage.instance);
});

final propertiesStreamProvider = StreamProvider<List<PropertyModel>>((ref) {
  return ref.watch(propertyRepositoryProvider).streamProperties();
});

final propertyProvider = FutureProvider.family<PropertyModel?, String>((ref, id) {
  return ref.watch(propertyRepositoryProvider).getProperty(id);
});

final savedPropertiesProvider = StreamProvider.family<List<PropertyModel>, String>((ref, userId) {
  return ref.watch(propertyRepositoryProvider).streamSavedProperties(userId);
});

final isPropertySavedProvider = StreamProvider.family<bool, ({String userId, String propertyId})>((ref, arg) {
  return ref.watch(propertyRepositoryProvider).isPropertySaved(arg.userId, arg.propertyId);
});

final propertiesByOwnerProvider = StreamProvider.family<List<PropertyModel>, String>((ref, ownerId) {
  return ref.watch(propertyRepositoryProvider).streamPropertiesByOwner(ownerId);
});

class PropertyRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PropertyRepository(this._firestore, this._storage);

  Future<List<String>> uploadImages(List<File> imageFiles, String propertyId) async {
    LoggerService.i('Property: Uploading ${imageFiles.length} images for property $propertyId');
    List<String> downloadUrls = [];
    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final ref = _storage.ref().child('properties/$propertyId/image_$i.jpg');
        final uploadTask = await ref.putFile(imageFiles[i]);
        final url = await uploadTask.ref.getDownloadURL();
        downloadUrls.add(url);
      }
      LoggerService.i('Property: Successfully uploaded ${downloadUrls.length} images');
      return downloadUrls;
    } catch (e, st) {
      LoggerService.e('Property: Image upload failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<String?> uploadVideo(File videoFile, String propertyId) async {
    LoggerService.i('Property: Uploading video for property $propertyId');
    try {
      final ref = _storage.ref().child('properties/$propertyId/video.mp4');
      final uploadTask = await ref.putFile(videoFile);
      final url = await uploadTask.ref.getDownloadURL();
      LoggerService.i('Property: Successfully uploaded video');
      return url;
    } catch (e, st) {
      LoggerService.e('Property: Video upload failed', error: e, stack: st);
      return null;
    }
  }

  Future<void> addProperty(PropertyModel property, List<File> imageFiles, {File? videoFile}) async {
    LoggerService.i('Property: Starting addProperty workflow for ${property.title}');
    try {
      List<String> imageUrls = [];
      
      // 1. Upload images and video if any
      if (imageFiles.isNotEmpty) {
        imageUrls = await uploadImages(imageFiles, property.id);
      }
      
      String? finalVideoUrl = property.videoUrl;
      if (videoFile != null) {
        finalVideoUrl = await uploadVideo(videoFile, property.id);
      }

      // 2. update property with images
      final completeProperty = PropertyModel(
        id: property.id,
        ownerId: property.ownerId,
        title: property.title,
        description: property.description,
        type: property.type,
        propertyType: property.propertyType,
        price: property.price,
        location: property.location,
        city: property.city,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        areaSqFt: property.areaSqFt,
        imageUrls: imageUrls,
        createdAt: property.createdAt,
        isVerified: property.isVerified,
        isZeroBrokerage: property.isZeroBrokerage,
        builtIn: property.builtIn,
        lotSizeSqFt: property.lotSizeSqFt,
        latitude: property.latitude,
        longitude: property.longitude,
        videoUrl: finalVideoUrl,
        panoramaUrl: property.panoramaUrl,
        amenities: property.amenities,
      );

      // 3. Save to Firestore
      await _firestore.collection('properties').doc(property.id).set(completeProperty.toMap());
      LoggerService.i('Property: Successfully saved property to Firestore. ID: ${property.id}');
    } catch (e, st) {
      LoggerService.e('Property: Failed to add property', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> deleteProperty(String propertyId) async {
    LoggerService.i('Property: Deleting property $propertyId');
    try {
      await _firestore.collection('properties').doc(propertyId).delete();
      LoggerService.i('Property: Successfully deleted property $propertyId');
    } catch (e, st) {
      LoggerService.e('Property: Failed to delete property $propertyId', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> updateProperty(PropertyModel property) async {
    LoggerService.i('Property: Updating property ${property.id}');
    try {
      await _firestore.collection('properties').doc(property.id).update(property.toMap());
      LoggerService.i('Property: Successfully updated property ${property.id}');
    } catch (e, st) {
      LoggerService.e('Property: Failed to update property ${property.id}', error: e, stack: st);
      rethrow;
    }
  }

  Stream<List<PropertyModel>> streamPropertiesByOwner(String ownerId) {
    LoggerService.i('Property: Streaming properties for owner $ownerId');
    return _firestore
        .collection('properties')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PropertyModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<PropertyModel>> streamProperties({String? city, String? type}) {
    LoggerService.i('Property: Streaming properties (Filters: City=$city, Type=$type)');
    
    Query query = _firestore.collection('properties');
    
    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }
    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) {
      LoggerService.i('Property: Received ${snapshot.docs.length} docs from Firestore');
      final properties = snapshot.docs.map((doc) {
        return PropertyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      // Sort in memory by createdAt descending
      properties.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return properties;
    });
  }

  Future<PropertyModel?> getProperty(String id) async {
    LoggerService.i('Property: Fetching property $id');
    try {
      final doc = await _firestore.collection('properties').doc(id).get();
      if (doc.exists) {
        LoggerService.i('Property: Found property ${doc.id}');
        return PropertyModel.fromMap(doc.data()!, doc.id);
      }
      LoggerService.w('Property: Property $id not found');
      return null;
    } catch (e, st) {
      LoggerService.e('Property: Error fetching property $id', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> toggleSaveProperty(String userId, String propertyId) async {
    LoggerService.i('Property: Toggling save for user $userId on property $propertyId');
    try {
      final docId = '${userId}_$propertyId';
      final doc = _firestore.collection('saved_properties').doc(docId);
      final existing = await doc.get();
      
      if (existing.exists) {
        LoggerService.i('Property: Removing from saved list');
        await doc.delete();
      } else {
        LoggerService.i('Property: Adding to saved list');
        await doc.set({
          'userId': userId,
          'propertyId': propertyId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e, st) {
      LoggerService.e('Property: Failed to toggle save', error: e, stack: st);
      rethrow;
    }
  }

  Stream<bool> isPropertySaved(String userId, String propertyId) {
    final docId = '${userId}_$propertyId';
    return _firestore.collection('saved_properties').doc(docId).snapshots().map((snapshot) => snapshot.exists);
  }

  Stream<List<PropertyModel>> streamSavedProperties(String userId) {
    LoggerService.i('Property: Streaming saved properties for user $userId');
    return _firestore
        .collection('saved_properties')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final propertyIds = snapshot.docs.map((doc) => doc['propertyId'] as String).toList();
      if (propertyIds.isEmpty) return [];

      // Fetch each property details
      final propertyFutures = propertyIds.map((id) => getProperty(id));
      final properties = await Future.wait(propertyFutures);
      final result = properties.whereType<PropertyModel>().toList();
      
      final idToTimestamp = {
        for (var doc in snapshot.docs) doc['propertyId'] as String: doc['timestamp'] as Timestamp?
      };
      
      result.sort((a, b) {
        final tsA = idToTimestamp[a.id] ?? Timestamp.now();
        final tsB = idToTimestamp[b.id] ?? Timestamp.now();
        return tsB.compareTo(tsA);
      });
      
      return result;
    });
  }
}
