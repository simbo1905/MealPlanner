import 'package:freezed_annotation/freezed_annotation.dart';
import 'recipe.freezed_model.dart';

part 'workspace_recipe.freezed_model.freezed.dart';
part 'workspace_recipe.freezed_model.g.dart';

enum WorkspaceRecipeStatus { draft, incomplete, ready }

@freezed
class WorkspaceRecipe with _$WorkspaceRecipe {
  const factory WorkspaceRecipe({
    required String id,
    required Recipe recipe,
    required WorkspaceRecipeStatus status,
    @Default([]) List<String> missingFields,
    @Default([]) List<String> photoIds,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WorkspaceRecipe;

  factory WorkspaceRecipe.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceRecipeFromJson(json);
}
