import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Configuration for planmise project
const firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyDDummyKeyForPlanmise',
  appId: '1:123456789:web:planmiseDev',
  messagingSenderId: '123456789',
  projectId: 'planmise',
  authDomain: 'planmise.firebaseapp.com',
  storageBucket: 'planmise.appspot.com',
);

const String collectionName = 'recipesv1';
const int batchSize = 100; // Firestore batch write limit

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart upload_recipes.dart <recipes_file_path>');
    exit(1);
  }

  final recipesFile = File(args[0]);

  if (!recipesFile.existsSync()) {
    print('Error: File not found: ${recipesFile.path}');
    exit(1);
  }

  try {
    // Initialize Firebase
    print('Initializing Firebase for project: planmise...');
    await Firebase.initializeApp(options: firebaseOptions);

    final firestore = FirebaseFirestore.instance;

    // Read recipe titles from file
    print('Reading recipe titles from file...');
    final lines = recipesFile.readAsLinesSync();
    final recipes = lines
        .where((line) => line.trim().isNotEmpty)
        .map((title) => {
          'title': title.trim(),
          'titleLower': title.trim().toLowerCase(),
          'titleWords': title.trim().toLowerCase().split(' ').where((w) => w.length > 2).toList(),
          'createdAt': FieldValue.serverTimestamp()
        })
        .toList();

    print('Found ${recipes.length} recipes to upload.');

    // Upload recipes in batches directly to recipesv1 collection
    int uploaded = 0;
    for (int i = 0; i < recipes.length; i += batchSize) {
      final batch = firestore.batch();
      final end = (i + batchSize < recipes.length) ? i + batchSize : recipes.length;

      for (int j = i; j < end; j++) {
        final docRef = firestore.collection(collectionName).doc();
        batch.set(docRef, recipes[j]);
      }

      await batch.commit();
      uploaded += (end - i);
      print('Uploaded $uploaded/${recipes.length} recipes...');
    }

    print('✓ Successfully uploaded ${recipes.length} recipes to $collectionName collection');
  } catch (e) {
    print('Error uploading recipes: $e');
    exit(1);
  }
}