import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recipe.freezed_model.dart';
import '../../providers/recipes_v1_provider.dart';

/// Autocomplete widget for recipe search with debouncing and keyboard navigation
class RecipeSearchAutocomplete extends ConsumerStatefulWidget {
  final Function(Recipe recipe)? onRecipeSelected;
  final TextEditingController? controller;

  const RecipeSearchAutocomplete({
    Key? key,
    this.onRecipeSelected,
    this.controller,
  }) : super(key: key);

  @override
  ConsumerState<RecipeSearchAutocomplete> createState() =>
      _RecipeSearchAutocompleteState();
}

class _RecipeSearchAutocompleteState
    extends ConsumerState<RecipeSearchAutocomplete> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  int _selectedIndex = -1;
  List<Recipe> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _selectedIndex = -1;
    });
  }

  void _selectRecipe(Recipe recipe) {
    widget.onRecipeSelected?.call(recipe);
    _controller.clear();
    _showSuggestions = false;
    setState(() {
      _selectedIndex = -1;
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (!_showSuggestions || _suggestions.isEmpty) {
      return;
    }

    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % _suggestions.length;
      });
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      setState(() {
        _selectedIndex =
            (_selectedIndex - 1) < 0 ? _suggestions.length - 1 : _selectedIndex - 1;
      });
    } else if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      if (_selectedIndex >= 0 && _selectedIndex < _suggestions.length) {
        _selectRecipe(_suggestions[_selectedIndex]);
      }
    } else if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text;

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Type to search for recipes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _showSuggestions = false;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _showSuggestions = value.isNotEmpty;
              });
            },
            onTap: () {
              setState(() {
                _showSuggestions = query.isNotEmpty;
              });
            },
          ),
          if (_showSuggestions && query.isNotEmpty)
            Consumer(
              builder: (context, watch, child) {
                final searchResults = ref.watch(
                  recipeSearchV1NotifierProvider(query),
                );

                return searchResults.when(
                  data: (recipes) {
                    _suggestions = recipes;
                    if (recipes.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'No recipes found for "$query"',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }

                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          final isSelected = index == _selectedIndex;

                          return Material(
                            color: isSelected
                                ? Colors.blue[100]
                                : Colors.transparent,
                            child: InkWell(
                              onTap: () => _selectRecipe(recipe),
                              onHover: (hovering) {
                                if (hovering) {
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.title ?? 'Untitled Recipe',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (recipe.ingredientNamesNormalized != null &&
                                        recipe.ingredientNamesNormalized!
                                            .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          recipe.ingredientNamesNormalized!
                                              .take(3)
                                              .join(', '),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (error, stack) => Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Error: $error',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
