import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workspace_recipe.freezed_model.dart';
import '../../providers/recipe_providers.dart';
import '../../widgets/onboarding/recipe_workspace_widget.dart';

class RecipeReviewScreen extends ConsumerStatefulWidget {
  final WorkspaceRecipe workspace;

  const RecipeReviewScreen({
    super.key,
    required this.workspace,
  });

  @override
  ConsumerState<RecipeReviewScreen> createState() => _RecipeReviewScreenState();
}

class _RecipeReviewScreenState extends ConsumerState<RecipeReviewScreen> {
  late WorkspaceRecipe _currentWorkspace;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentWorkspace = widget.workspace;
  }

  Future<void> _saveRecipe() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final saveNotifier = ref.read(recipeSaveNotifierProvider.notifier);
      await saveNotifier.save(_currentWorkspace.recipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving recipe: $e')),
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

  Future<void> _discardRecipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Recipe?'),
        content: const Text('Are you sure you want to discard this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Recipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _discardRecipe,
            tooltip: 'Discard recipe',
          ),
        ],
      ),
      body: RecipeWorkspaceWidget(
        workspace: _currentWorkspace,
        onChanged: (updated) {
          setState(() {
            _currentWorkspace = updated;
          });
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveRecipe,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Accept & Save'),
          ),
        ),
      ),
    );
  }
}
