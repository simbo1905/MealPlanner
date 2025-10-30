import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

Future<void> main(List<String> args) async {
  const String batchDir = '.tmp/recipesv1_batches';
  const int maxRetriesPerBatch = 3;

  try {
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firestore = FirebaseFirestore.instance;
    print('Connected to Firebase project: ${firestore.app.options.projectId}');

    final batchDirectory = Directory(batchDir);
    if (!batchDirectory.existsSync()) {
      stderr.writeln('Error: Batch directory not found at $batchDir');
      exit(1);
    }

    final batchFiles = batchDirectory
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    if (batchFiles.isEmpty) {
      stderr.writeln('Error: No JSON batch files found in $batchDir');
      exit(1);
    }

    batchFiles.sort((a, b) => a.path.compareTo(b.path));

    print('Found ${batchFiles.length} batch files to upload');

    int totalUploaded = 0;
    int totalErrors = 0;

    for (var file in batchFiles) {
      print('\nProcessing ${file.path}...');

      int retries = 0;
      bool success = false;

      while (retries < maxRetriesPerBatch && !success) {
        try {
          final jsonContent = file.readAsStringSync();
          final recipes = (jsonDecode(jsonContent) as List)
              .cast<Map<String, dynamic>>();

          // Upload in Firestore batches (max 500 operations)
          final batch = firestore.batch();
          int batchOps = 0;

          for (var recipe in recipes) {
            final docRef = firestore.collection('recipes_v1').doc(recipe['id']);
            batch.set(docRef, recipe);
            batchOps++;
          }

          await batch.commit();
          totalUploaded += recipes.length;
          print('  ✓ Uploaded ${recipes.length} recipes (Total: $totalUploaded)');
          success = true;
        } catch (e) {
          retries++;
          if (retries < maxRetriesPerBatch) {
            print('  ⚠ Error (retry $retries/$maxRetriesPerBatch): $e');
            await Future.delayed(Duration(seconds: 2 * retries));
          } else {
            stderr.writeln('  ✗ Failed after $maxRetriesPerBatch retries: $e');
            totalErrors += 1;
          }
        }
      }
    }

    print('\n' + '=' * 60);
    print('Upload Complete!');
    print('Total recipes uploaded: $totalUploaded');
    print('Failed batches: $totalErrors');
    print('=' * 60);

    // Validate total count
    print('\nValidating total count in Firestore...');
    final snapshot = await firestore.collection('recipes_v1').count().get();
    final totalCount = snapshot.count ?? 0;

    print('Total recipes in Firestore: $totalCount');

    if (totalCount == totalUploaded) {
      print('✓ Validation successful!');
    } else {
      stderr.writeln(
        '⚠ Warning: Expected $totalUploaded recipes but found $totalCount',
      );
    }

    if (totalErrors > 0) {
      exit(1);
    }
  } catch (e) {
    stderr.writeln('Fatal error: $e');
    exit(1);
  }
}
