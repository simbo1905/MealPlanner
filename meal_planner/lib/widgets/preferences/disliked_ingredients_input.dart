import 'package:flutter/material.dart';

/// Widget for managing disliked ingredients with chip display and autocomplete
class DislikedIngredientsInput extends StatefulWidget {
  final List<String> dislikedIngredients;
  final ValueChanged<List<String>> onChanged;
  final List<String>? existingIngredients;

  const DislikedIngredientsInput({
    required this.dislikedIngredients,
    required this.onChanged,
    this.existingIngredients,
    super.key,
  });

  @override
  State<DislikedIngredientsInput> createState() =>
      _DislikedIngredientsInputState();
}

class _DislikedIngredientsInputState extends State<DislikedIngredientsInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addIngredient(String ingredient) {
    final trimmed = ingredient.trim();
    if (trimmed.isEmpty) return;
    if (widget.dislikedIngredients.contains(trimmed)) return;

    final updated = [...widget.dislikedIngredients, trimmed];
    widget.onChanged(updated);
    _controller.clear();
  }

  void _removeIngredient(String ingredient) {
    final updated = List<String>.from(widget.dislikedIngredients);
    updated.remove(ingredient);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.existingIngredients != null) {
      return _buildWithAutocomplete();
    } else {
      return _buildSimple();
    }
  }

  Widget _buildSimple() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disliked Ingredients',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter ingredient',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: _addIngredient,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addIngredient(_controller.text),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: widget.dislikedIngredients.map((ingredient) {
            return Chip(
              label: Text(ingredient),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => _removeIngredient(ingredient),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWithAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disliked Ingredients',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return widget.existingIngredients!.where((ingredient) {
              return ingredient
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: _addIngredient,
          fieldViewBuilder: (
            context,
            controller,
            focusNode,
            onFieldSubmitted,
          ) {
            // Use our controller instead
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Enter ingredient',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      _addIngredient(value);
                      controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _addIngredient(controller.text);
                    controller.clear();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: widget.dislikedIngredients.map((ingredient) {
            return Chip(
              label: Text(ingredient),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => _removeIngredient(ingredient),
            );
          }).toList(),
        ),
      ],
    );
  }
}
