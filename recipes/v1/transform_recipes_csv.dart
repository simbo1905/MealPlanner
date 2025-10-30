import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';

void main(List<String> args) async {
  const String csvPath = '.tmp/recipes.csv';
  const String outputDir = '.tmp/recipesv1_batches';
  const int batchSize = 500;

  try {
    print('Reading CSV file from $csvPath...');
    final csvFile = File(csvPath);

    if (!csvFile.existsSync()) {
      stderr.writeln('Error: CSV file not found at $csvPath');
      exit(1);
    }

    final csvContent = csvFile.readAsStringSync();
    final rows = const CsvToListConverter().convert(csvContent);

    if (rows.isEmpty) {
      stderr.writeln('Error: CSV file is empty');
      exit(1);
    }

    // Parse header row
    final headers = (rows[0] as List).cast<String>();
    final titleIdx = headers.indexOf('Title');
    final ingredientsIdx = headers.indexOf('Ingredients');
    final instructionsIdx = headers.indexOf('Instructions');
    final cleanedIngredientsIdx = headers.indexOf('Cleaned_Ingredients');

    if (titleIdx == -1 || ingredientsIdx == -1 || instructionsIdx == -1) {
      stderr.writeln('Error: Missing required columns: Title, Ingredients, Instructions');
      exit(1);
    }

    // Create output directory
    final outputDirFile = Directory(outputDir);
    if (!outputDirFile.existsSync()) {
      outputDirFile.createSync(recursive: true);
    }

    print('Processing ${rows.length - 1} recipes...');

    const uuid = Uuid();
    int recipeCount = 0;
    int batchNumber = 1;
    List<Map<String, dynamic>> currentBatch = [];

    for (int i = 1; i < rows.length; i++) {
      final row = (rows[i] as List);

      try {
        final title = _normalizeString(row[titleIdx]?.toString() ?? '');
        final ingredients = row[ingredientsIdx]?.toString() ?? '';
        final instructions = row[instructionsIdx]?.toString() ?? '';

        if (title.isEmpty) {
          // Skip recipes with no title
          continue;
        }

        // Extract ingredient names from Cleaned_Ingredients if available
        final cleanedIngredients = cleanedIngredientsIdx >= 0 
            ? row[cleanedIngredientsIdx]?.toString() ?? '' 
            : '';
        final ingredientNamesNormalized = _parseIngredients(cleanedIngredients);

        final recipe = {
          'id': uuid.v4(),
          'title': title,
          'titleLower': title.toLowerCase(),
          'titleTokens': _tokenizeTitle(title),
          'ingredients': ingredients,
          'instructions': instructions,
          'ingredientNamesNormalized': ingredientNamesNormalized,
          'createdAt': DateTime.now().toIso8601String(),
          'version': 'v1',
        };

        currentBatch.add(recipe);
        recipeCount++;

        if (currentBatch.length >= batchSize) {
          await _writeBatch(outputDir, batchNumber, currentBatch);
          print('Batch $batchNumber written (${currentBatch.length} recipes, total: $recipeCount)');
          currentBatch = [];
          batchNumber++;
        }
      } catch (e) {
        stderr.writeln('Warning: Failed to parse row $i: $e');
        continue;
      }
    }

    // Write remaining recipes
    if (currentBatch.isNotEmpty) {
      await _writeBatch(outputDir, batchNumber, currentBatch);
      print('Batch $batchNumber written (${currentBatch.length} recipes, total: $recipeCount)');
    }

    print('✓ Transformation complete!');
    print('  Total recipes: $recipeCount');
    print('  Output directory: $outputDir');
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}

Future<void> _writeBatch(
  String outputDir,
  int batchNumber,
  List<Map<String, dynamic>> recipes,
) async {
  final fileName = 'batch_${batchNumber.toString().padLeft(3, '0')}.json';
  final filePath = '$outputDir/$fileName';
  final file = File(filePath);

  final jsonData = jsonEncode(recipes);
  await file.writeAsString(jsonData);
}

String _normalizeString(String input) {
  return input.trim();
}

List<String> _tokenizeTitle(String title) {
  return title
      .toLowerCase()
      .split(RegExp(r'[\s\-_]+'))
      .where((token) => token.isNotEmpty)
      .toList();
}

List<String> _parseIngredients(String cleanedIngredients) {
  if (cleanedIngredients.isEmpty) return [];

  try {
    // Try to parse as JSON array first (e.g., "['item1', 'item2']")
    var cleaned = cleanedIngredients.replaceAll("'", '"');
    if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
      try {
        final list = jsonDecode(cleaned) as List;
        return list
            .map((item) => _normalizeIngredient(item.toString()))
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList();
      } catch (_) {
        // Fall through to comma-separated parsing
      }
    }

    // Parse as comma-separated list
    return cleanedIngredients
        .split(',')
        .map((item) => _normalizeIngredient(item))
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  } catch (e) {
    stderr.writeln('Warning: Failed to parse ingredients: $cleanedIngredients');
    return [];
  }
}

String _normalizeIngredient(String ingredient) {
  return ingredient
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'^[\[\'"]+'), '')
      .replaceAll(RegExp(r'[\]\'"]+$'), '')
      .trim();
}
