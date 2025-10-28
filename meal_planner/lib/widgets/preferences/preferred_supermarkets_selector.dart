import 'package:flutter/material.dart';

/// Widget for selecting preferred supermarkets with search functionality
class PreferredSupermarketsSelector extends StatefulWidget {
  final List<String> selectedSupermarkets;
  final ValueChanged<List<String>> onChanged;
  final List<String> availableSupermarkets;

  const PreferredSupermarketsSelector({
    required this.selectedSupermarkets,
    required this.onChanged,
    this.availableSupermarkets = const [
      'Whole Foods',
      'Trader Joe\'s',
      'Safeway',
      'Kroger',
      'Albertsons',
      'Costco',
      'Walmart',
      'Target',
    ],
    super.key,
  });

  @override
  State<PreferredSupermarketsSelector> createState() =>
      _PreferredSupermarketsSelectorState();
}

class _PreferredSupermarketsSelectorState
    extends State<PreferredSupermarketsSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSupermarket(String supermarket) {
    final updated = List<String>.from(widget.selectedSupermarkets);
    if (updated.contains(supermarket)) {
      updated.remove(supermarket);
    } else {
      updated.add(supermarket);
    }
    widget.onChanged(updated);
  }

  List<String> get _filteredSupermarkets {
    if (_searchQuery.isEmpty) {
      return widget.availableSupermarkets;
    }
    return widget.availableSupermarkets.where((supermarket) {
      return supermarket.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Supermarkets',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search supermarkets...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        const SizedBox(height: 8),
        ..._filteredSupermarkets.map((supermarket) {
          final isSelected = widget.selectedSupermarkets.contains(supermarket);
          return CheckboxListTile(
            title: Text(supermarket),
            value: isSelected,
            onChanged: (_) => _toggleSupermarket(supermarket),
            controlAffinity: ListTileControlAffinity.leading,
          );
        }),
      ],
    );
  }
}
