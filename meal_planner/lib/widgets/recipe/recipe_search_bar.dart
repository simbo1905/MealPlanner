import 'package:flutter/material.dart';

/// RecipeSearchBar provides a search input field with clear button.
class RecipeSearchBar extends StatefulWidget {
  final Function(String query) onChanged;
  final Function(String query)? onSearchTriggered;
  final String? hintText;

  const RecipeSearchBar({
    super.key,
    required this.onChanged,
    this.onSearchTriggered,
    this.hintText,
  });

  @override
  State<RecipeSearchBar> createState() => _RecipeSearchBarState();
}

class _RecipeSearchBarState extends State<RecipeSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Search recipes...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _controller.clear();
                    widget.onChanged('');
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onChanged: (value) {
        setState(() {});
        widget.onChanged(value);
      },
      onSubmitted: (value) {
        widget.onSearchTriggered?.call(value);
      },
    );
  }
}
