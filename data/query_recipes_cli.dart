#!/usr/bin/env dart

// Simple Firestore prefix query CLI using dart_firebase_admin.
// Usage: dart run data/query_recipes_cli.dart <search_term>

import 'dart:io';

import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run data/query_recipes_cli.dart <search_term>');
    exitCode = 64; // EX_USAGE
    return;
  }

  final searchTerm = args.first.toLowerCase();

  final serviceAccountPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
  if (serviceAccountPath == null || serviceAccountPath.isEmpty) {
    stderr.writeln('GOOGLE_APPLICATION_CREDENTIALS env var is not set.');
    stderr.writeln('Set it to the absolute path of a Firebase service account JSON.');
    exitCode = 78; // EX_CONFIG
    return;
  }

  try {
    final app = FirebaseAdminApp.initializeApp(
      'planmise',
      Credential.fromServiceAccount(File(serviceAccountPath)),
    );

    final firestore = Firestore(app);

    stdout.writeln('Querying recipesv1 for prefix "$searchTerm"...');

    final snapshot = await firestore
        .collection('recipesv1')
        .where('titleLower.stringValue', WhereFilter.greaterThanOrEqual, searchTerm)
        .where('titleLower.stringValue', WhereFilter.lessThanOrEqual, '$searchTerm\uf8ff')
        .limit(10)
        .get();

    if (snapshot.docs.isEmpty) {
      stdout.writeln('No recipes found.');
      return;
    }

    for (final doc in snapshot.docs) {
      final data = doc.data();
      var title = data['title'];
      
      // Handle nested map structure if present (due to data loading issue)
      if (title is Map) {
        title = title['stringValue'] ?? title;
      }
      
      title = title ?? '(no title)';
      stdout.writeln('${doc.id}: $title');
    }
    
    // Clean up
    
  } catch (error) {
    stderr.writeln('Failed to query Firestore: $error');
    exitCode = 1;
  }
}