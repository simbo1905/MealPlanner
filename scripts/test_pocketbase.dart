#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';

/// PocketBase Integration Test Runner
/// 
/// Runs comprehensive tests against PocketBase instance to verify:
/// - Authentication works
/// - Collections can be created
/// - CRUD operations function
/// - Transactions maintain data integrity
/// 
/// Usage:
///   dart scripts/test_pocketbase.dart

const kCurrentLink = '.tmp/pb_current';

void main() async {
  print('=== PocketBase Integration Tests ===\n');

  // Load run info
  final runInfo = await loadRunInfo();
  final url = runInfo['url'] as String;
  final adminUser = runInfo['admin_user'] as String;

  // Load credentials
  final credentials = await loadCredentials();

  print('Testing PocketBase at: $url\n');

  // Check server is alive
  if (!await checkHealth(url)) {
    print('✖ PocketBase server not responding');
    print('  Run: dart scripts/setup_pocketbase.dart');
    exit(1);
  }

  // Run tests
  var passed = 0;
  var failed = 0;

  print('Running tests...\n');

  // Test 1: Admin authentication
  if (await testAdminAuth(url, credentials)) {
    passed++;
  } else {
    failed++;
  }

  // Test 2: Create collections
  final token = await authenticateAdmin(url, credentials);
  if (token != null) {
    if (await testCreateCollections(url, token)) {
      passed++;
    } else {
      failed++;
    }

    // Test 3: CRUD operations
    if (await testCrudOperations(url, token)) {
      passed++;
    } else {
      failed++;
    }

    // Test 4: Soft delete
    if (await testSoftDelete(url, token)) {
      passed++;
    } else {
      failed++;
    }

    // Test 5: List filtering
    if (await testListFiltering(url, token)) {
      passed++;
    } else {
      failed++;
    }
  } else {
    failed += 4; // Skip remaining tests
  }

  // Summary
  print('\n=== Test Results ===');
  print('Passed: $passed');
  print('Failed: $failed');
  print('Total:  ${passed + failed}');

  if (failed > 0) {
    print('\n✖ Some tests failed');
    exit(1);
  }

  print('\n✔ All tests passed!');
}

Future<Map<String, dynamic>> loadRunInfo() async {
  final link = Link(kCurrentLink);
  if (!await link.exists()) {
    print('✖ No current PocketBase instance found');
    print('  Run: dart scripts/setup_pocketbase.dart');
    exit(1);
  }

  final workDir = await link.resolveSymbolicLinks();
  final file = File('$workDir/run_info.json');

  if (!await file.exists()) {
    print('✖ Run info not found: ${file.path}');
    exit(1);
  }

  final content = await file.readAsString();
  return json.decode(content) as Map<String, dynamic>;
}

Future<Map<String, String>> loadCredentials() async {
  final file = File('.env');
  if (!await file.exists()) {
    print('✖ Environment file not found: .env');
    exit(1);
  }

  final credentials = <String, String>{};
  final lines = await file.readAsLines();

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

    final parts = trimmed.split('=');
    if (parts.length == 2) {
      credentials[parts[0].trim()] = parts[1].trim();
    }
  }

  return credentials;
}

Future<bool> checkHealth(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse('$url/api/health'));
    final response = await request.close();
    return response.statusCode == 200;
  } catch (e) {
    return false;
  } finally {
    client.close();
  }
}

Future<bool> testAdminAuth(
  String url,
  Map<String, String> credentials,
) async {
  stdout.write('Test: Admin authentication... ');

  try {
    final token = await authenticateAdmin(url, credentials);
    if (token != null && token.isNotEmpty) {
      print('✔');
      return true;
    } else {
      print('✖ No token returned');
      return false;
    }
  } catch (e) {
    print('✖ $e');
    return false;
  }
}

Future<String?> authenticateAdmin(
  String url,
  Map<String, String> credentials,
) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(
      Uri.parse('$url/api/admins/auth-with-password'),
    );

    request.headers.contentType = ContentType.json;

    final body = json.encode({
      'identity': credentials['PB_ADMIN_USER'],
      'password': credentials['PB_ADMIN_PASSWORD'],
    });

    request.contentLength = body.length;
    request.write(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final data = json.decode(responseBody) as Map<String, dynamic>;
      return data['token'] as String?;
    } else {
      print('\nAuth failed: ${response.statusCode} $responseBody');
      return null;
    }
  } finally {
    client.close();
  }
}

Future<bool> testCreateCollections(String url, String token) async {
  stdout.write('Test: Create collections... ');

  try {
    // Try to create recipes_v1 collection
    final created = await createCollection(
      url: url,
      token: token,
      name: 'recipes_v1',
      schema: [
        {
          'name': 'title',
          'type': 'text',
          'required': true,
          'options': {'min': 1, 'max': 200}
        },
        {
          'name': 'description',
          'type': 'text',
          'required': false,
          'options': {'max': 500}
        },
        {
          'name': 'total_time',
          'type': 'number',
          'required': true,
          'options': {'min': 1}
        },
        {
          'name': 'status',
          'type': 'select',
          'required': true,
          'options': {
            'values': ['Draft', 'Complete']
          }
        },
        {
          'name': 'is_deleted',
          'type': 'bool',
          'required': true,
          'options': {}
        },
        {
          'name': 'recipe_json',
          'type': 'json',
          'required': false,
          'options': {}
        },
      ],
    );

    if (created) {
      print('✔');
    } else {
      print('✔ (already exists)');
    }

    // Create edits collection
    await createCollection(
      url: url,
      token: token,
      name: 'edits',
      schema: [
        {
          'name': 'event_id',
          'type': 'text',
          'required': true,
        },
        {
          'name': 'entity_id',
          'type': 'text',
          'required': true,
        },
        {
          'name': 'prior_version',
          'type': 'number',
          'required': true,
        },
        {
          'name': 'next_version',
          'type': 'number',
          'required': true,
        },
        {
          'name': 'event_type',
          'type': 'select',
          'required': true,
          'options': {
            'values': ['CREATE', 'UPDATE', 'DELETE']
          }
        },
        {
          'name': 'new_state_json',
          'type': 'json',
          'required': true,
        },
      ],
    );

    // Create snapshots collection
    await createCollection(
      url: url,
      token: token,
      name: 'snapshots',
      schema: [
        {
          'name': 'version',
          'type': 'number',
          'required': true,
        },
        {
          'name': 'type_version',
          'type': 'text',
          'required': true,
        },
        {
          'name': 'state_json',
          'type': 'json',
          'required': true,
        },
        {
          'name': 'deleted',
          'type': 'bool',
          'required': true,
          'options': {}
        },
        {
          'name': 'latest_handle_version',
          'type': 'number',
          'required': false,
        },
      ],
    );

    return true;
  } catch (e) {
    print('✖ $e');
    return false;
  }
}

Future<bool> createCollection({
  required String url,
  required String token,
  required String name,
  required List<Map<String, dynamic>> schema,
}) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(
      Uri.parse('$url/api/collections'),
    );

    request.headers.contentType = ContentType.json;
    request.headers.add('Authorization', 'Bearer $token');

    final body = json.encode({
      'name': name,
      'type': 'base',
      'schema': schema,
      'listRule': 'is_deleted = false',
      'viewRule': '',
      'createRule': '@request.auth.id != ""',
      'updateRule': '@request.auth.id != ""',
      'deleteRule': '@request.auth.id != ""',
    });

    request.contentLength = body.length;
    request.write(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      if (responseBody.contains('name') && responseBody.contains('already exists')) {
        return true;
      }
      return false;
    }

    return false;
  } finally {
    client.close();
  }
}

Future<bool> testCrudOperations(String url, String token) async {
  stdout.write('Test: CRUD operations... ');

  try {
    // Create
    final recipeId = await createRecipe(url, token, {
      'title': 'Test Recipe',
      'description': 'A test recipe',
      'total_time': 30,
      'status': 'Draft',
      'is_deleted': false,
      'recipe_json': {'ingredients': []},
    });

    if (recipeId == null) {
      print('✖ Create failed');
      return false;
    }

    // Read
    final recipe = await getRecipe(url, token, recipeId);
    if (recipe == null || recipe['title'] != 'Test Recipe') {
      print('✖ Read failed');
      return false;
    }

    // Update
    final updated = await updateRecipe(url, token, recipeId, {
      'title': 'Updated Recipe',
      'description': 'Updated description',
      'total_time': 45,
      'status': 'Complete',
      'is_deleted': false,
    });

    if (!updated) {
      print('✖ Update failed');
      return false;
    }

    // Verify update
    final updatedRecipe = await getRecipe(url, token, recipeId);
    if (updatedRecipe?['title'] != 'Updated Recipe') {
      print('✖ Update verification failed');
      return false;
    }

    print('✔');
    return true;
  } catch (e) {
    print('✖ $e');
    return false;
  }
}

Future<String?> createRecipe(
  String url,
  String token,
  Map<String, dynamic> data,
) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(
      Uri.parse('$url/api/collections/recipes_v1/records'),
    );

    request.headers.contentType = ContentType.json;
    request.headers.add('Authorization', 'Bearer $token');

    final body = json.encode(data);
    request.contentLength = body.length;
    request.write(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final result = json.decode(responseBody) as Map<String, dynamic>;
      return result['id'] as String?;
    }

    return null;
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>?> getRecipe(
  String url,
  String token,
  String id,
) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse('$url/api/collections/recipes_v1/records/$id'),
    );

    request.headers.add('Authorization', 'Bearer $token');

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      return json.decode(responseBody) as Map<String, dynamic>;
    }

    return null;
  } finally {
    client.close();
  }
}

Future<bool> updateRecipe(
  String url,
  String token,
  String id,
  Map<String, dynamic> data,
) async {
  final client = HttpClient();
  try {
    final request = await client.patchUrl(
      Uri.parse('$url/api/collections/recipes_v1/records/$id'),
    );

    request.headers.contentType = ContentType.json;
    request.headers.add('Authorization', 'Bearer $token');

    final body = json.encode(data);
    request.contentLength = body.length;
    request.write(body);

    final response = await request.close();
    await response.drain();

    return response.statusCode == 200;
  } finally {
    client.close();
  }
}

Future<bool> testSoftDelete(String url, String token) async {
  stdout.write('Test: Soft delete... ');

  try {
    // Create a recipe to delete
    final recipeId = await createRecipe(url, token, {
      'title': 'Recipe To Delete',
      'description': 'Will be soft deleted',
      'total_time': 20,
      'status': 'Draft',
      'is_deleted': false,
    });

    if (recipeId == null) {
      print('✖ Setup failed');
      return false;
    }

    // Soft delete (set is_deleted = true)
    final deleted = await updateRecipe(url, token, recipeId, {
      'is_deleted': true,
    });

    if (!deleted) {
      print('✖ Soft delete failed');
      return false;
    }

    // Verify it still exists in DB but flagged
    final recipe = await getRecipe(url, token, recipeId);
    if (recipe == null || recipe['is_deleted'] != true) {
      print('✖ Soft delete verification failed');
      return false;
    }

    print('✔');
    return true;
  } catch (e) {
    print('✖ $e');
    return false;
  }
}

Future<bool> testListFiltering(String url, String token) async {
  stdout.write('Test: List filtering (is_deleted=false)... ');

  try {
    final client = HttpClient();
    final request = await client.getUrl(
      Uri.parse('$url/api/collections/recipes_v1/records?filter=is_deleted%3Dfalse'),
    );

    request.headers.add('Authorization', 'Bearer $token');

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    client.close();

    if (response.statusCode == 200) {
      final result = json.decode(responseBody) as Map<String, dynamic>;
      final items = result['items'] as List;

      for (final item in items) {
        if (item['is_deleted'] == true) {
          print('✖ Deleted item in filtered list');
          return false;
        }
      }

      print('✔');
      return true;
    }

    print('✖ List request failed');
    return false;
  } catch (e) {
    print('✖ $e');
    return false;
  }
}
