import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/pocketbase_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe? recipe;

  const RecipeDetailScreen({Key? key, this.recipe}) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final PocketBaseService _pb = PocketBaseService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _totalTimeController;

  bool _isSaving = false;
  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.recipe?.description ?? '');
    _totalTimeController = TextEditingController(
        text: widget.recipe?.totalTime.toInt().toString() ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalTimeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final recipe = Recipe(
        uuid: widget.recipe?.uuid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        totalTime: double.tryParse(_totalTimeController.text) ?? 30,
        imageUrl: widget.recipe?.imageUrl ?? '',
        notes: widget.recipe?.notes ?? '',
        preReqs: widget.recipe?.preReqs ?? [],
        ingredients: widget.recipe?.ingredients ?? [],
        steps: widget.recipe?.steps ?? [],
      );

      if (_isEditing) {
        final updated = await _pb.updateRecipe(widget.recipe!.uuid!, recipe);
        if (mounted) {
          Navigator.pop(context, updated);
        }
      } else {
        final created = await _pb.createRecipe(recipe);
        if (mounted) {
          Navigator.pop(context, created);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recipe' : 'New Recipe'),
        actions: [
          TextButton(
            key: const Key('save-button'),
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title *',
                border: OutlineInputBorder(),
                hintText: 'e.g., Spaghetti Bolognese',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'Brief description of the recipe',
              ),
              maxLines: 3,
              maxLength: 250,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalTimeController,
              decoration: const InputDecoration(
                labelText: 'Total Time (minutes)',
                border: OutlineInputBorder(),
                hintText: 'e.g., 30',
                suffixText: 'min',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Time is required';
                }
                final time = int.tryParse(value.trim());
                if (time == null || time < 1) {
                  return 'Enter a valid time (at least 1 minute)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Simplified Form',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a simplified recipe form for testing PocketBase integration. '
                      'Full ingredient and step editing will be added in future updates.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: const Text('Save Recipe'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
