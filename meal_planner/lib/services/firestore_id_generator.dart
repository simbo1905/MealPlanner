import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility for generating Firestore-compatible document IDs.
/// Uses the same algorithm as Firestore's auto-generated IDs.
class FirestoreIdGenerator {
  static String generateId() {
    return FirebaseFirestore.instance.collection('_temp').doc().id;
  }

  static String generateIdForCollection(String collectionPath) {
    return FirebaseFirestore.instance.collection(collectionPath).doc().id;
  }
}
