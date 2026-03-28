import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/property_model.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return PropertyRepository(FirebaseFirestore.instance, FirebaseStorage.instance);
});

final propertiesStreamProvider = StreamProvider<List<PropertyModel>>((ref) {
  return ref.watch(propertyRepositoryProvider).streamProperties();
});

class PropertyRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PropertyRepository(this._firestore, this._storage);

  Future<List<String>> uploadImages(List<File> imageFiles, String propertyId) async {
    List<String> downloadUrls = [];
    for (int i = 0; i < imageFiles.length; i++) {
      final ref = _storage.ref().child('properties/$propertyId/image_$i.jpg');
      final uploadTask = await ref.putFile(imageFiles[i]);
      final url = await uploadTask.ref.getDownloadURL();
      downloadUrls.add(url);
    }
    return downloadUrls;
  }

  Future<void> addProperty(PropertyModel property, List<File> imageFiles) async {
    List<String> imageUrls = [];
    
    // 1. Upload images if any
    if (imageFiles.isNotEmpty) {
      imageUrls = await uploadImages(imageFiles, property.id);
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
    );

    // 3. Save to Firestore
    await _firestore.collection('properties').doc(property.id).set(completeProperty.toMap());
  }

  Stream<List<PropertyModel>> streamProperties({String? city, String? type}) {
    // If we have filters, we CANNOT use orderBy without a composite index.
    // So we perform filtering on Firestore and sorting in memory.
    Query query = _firestore.collection('properties');
    
    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }
    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) {
      final properties = snapshot.docs.map((doc) {
        return PropertyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      // Sort in memory by createdAt descending
      properties.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return properties;
    });
  }

  Future<PropertyModel?> getProperty(String id) async {
    final doc = await _firestore.collection('properties').doc(id).get();
    if (doc.exists) {
      return PropertyModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
