import 'dart:convert';
import 'dart:io';

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

  print('Initializing upload to Firestore...');
  
  // Get access token
  String accessToken = '';
  try {
    final tokenResult = await Process.run('firebase', ['auth:print-access-token']);
    if (tokenResult.exitCode == 0) {
      accessToken = tokenResult.stdout.toString().trim();
    } else {
      // Try gcloud
      final gcloudResult = await Process.run('gcloud', ['auth', 'print-access-token']);
      if (gcloudResult.exitCode == 0) {
        accessToken = gcloudResult.stdout.toString().trim();
      } else {
        print('Error: Could not get access token from firebase or gcloud CLI');
        exit(1);
      }
    }
  } catch (e) {
    print('Error getting access token: $e');
    exit(1);
  }

  // Read recipe titles
  print('Reading recipe titles from file...');
  final lines = recipesFile.readAsLinesSync();
  final recipes = lines.where((line) => line.trim().isNotEmpty).map((line) => line.trim()).toList();

  print('Found ${recipes.length} recipes to upload.');

  // Upload using Firestore REST API
  final projectId = 'planmise';
  final collectionName = 'recipesv1';
  
  int uploaded = 0;
  for (int i = 0; i < recipes.length; i++) {
    final title = recipes[i];
    final docId = 'recipe_${i.toString().padLeft(6, '0')}';
    
    final url = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName/$docId';
    
    final docData = {
      'fields': {
        'title': {'stringValue': title},
        'titleLower': {'stringValue': title.toLowerCase()},
        'titleWords': {
          'arrayValue': {
            'values': title.toLowerCase()
                .split(' ')
                .where((w) => w.length > 2)
                .map((w) => {'stringValue': w})
                .toList()
          }
        },
        'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
      }
    };

    try {
      final client = HttpClient();
      final request = await client.putUrl(Uri.parse(url));
      request.headers.add('Authorization', 'Bearer $accessToken');
      request.headers.add('Content-Type', 'application/json');
      
      request.add(utf8.encode(jsonEncode(docData)));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        uploaded++;
        if (uploaded % 100 == 0) {
          print('Uploaded $uploaded/${recipes.length} recipes...');
        }
      } else {
        print('Failed to upload recipe "$title": ${response.statusCode}');
      }
      
      await response.drain();
      client.close();
    } catch (e) {
      print('Error uploading recipe "$title": $e');
    }
  }
  
  print('✓ Successfully uploaded $uploaded recipes to $collectionName collection');
}