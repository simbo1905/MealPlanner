import 'package:freezed_annotation/freezed_annotation.dart';
import 'recipe.freezed_model.dart';

part 'search_models.freezed_model.freezed.dart';
part 'search_models.freezed_model.g.dart';

enum SearchSortBy { title, totalTime, relevance }

@freezed
class SearchOptions with _$SearchOptions {
  const factory SearchOptions({
    String? query,
    int? maxTime,
    List<String>? ingredients,
    List<String>? excludeAllergens,
    int? limit,
    SearchSortBy? sortBy,
  }) = _SearchOptions;

  factory SearchOptions.fromJson(Map<String, dynamic> json) =>
      _$SearchOptionsFromJson(json);
}

@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    required Recipe recipe,
    required double score,
    required List<String> matchedFields,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}
