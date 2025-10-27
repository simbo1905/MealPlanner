#!/bin/bash
# Cleanup script to remove files not in specs

cd "$(dirname "$0")"

echo "=== Removing Event Store test files ==="
git rm test/unit/services/entity_handle_test.dart \
       test/unit/services/local_buffer_test.dart \
       test/unit/services/merge_arbitrator_test.dart \
       test/unit/models/store_event_test.dart

echo "=== Removing outdated test files ==="
git rm test/widget_test.dart \
       integration_test/app_test.dart \
       integration_test/offline_sync_test.dart \
       integration_test/calendar_web_test.dart

echo "=== Removing Firebase freezed models (1/4) ==="
git rm lib/models/ingredient.freezed_model.dart \
       lib/models/ingredient.freezed_model.freezed.dart \
       lib/models/ingredient.freezed_model.g.dart \
       lib/models/meal_assignment.freezed_model.dart \
       lib/models/meal_assignment.freezed_model.freezed.dart \
       lib/models/meal_assignment.freezed_model.g.dart \
       lib/models/meal_plan.freezed_model.dart \
       lib/models/meal_plan.freezed_model.freezed.dart \
       lib/models/meal_plan.freezed_model.g.dart

echo "=== Removing Firebase freezed models (2/4) ==="
git rm lib/models/recipe.freezed_model.dart \
       lib/models/recipe.freezed_model.freezed.dart \
       lib/models/recipe.freezed_model.g.dart \
       lib/models/search_models.freezed_model.dart \
       lib/models/search_models.freezed_model.freezed.dart \
       lib/models/search_models.freezed_model.g.dart \
       lib/models/shopping_list.freezed_model.dart \
       lib/models/shopping_list.freezed_model.freezed.dart \
       lib/models/shopping_list.freezed_model.g.dart

echo "=== Removing Firebase freezed models (3/4) ==="
git rm lib/models/user_preferences.freezed_model.dart \
       lib/models/user_preferences.freezed_model.freezed.dart \
       lib/models/user_preferences.freezed_model.g.dart \
       lib/models/workspace_recipe.freezed_model.dart \
       lib/models/workspace_recipe.freezed_model.freezed.dart \
       lib/models/workspace_recipe.freezed_model.g.dart

echo "=== Removing Firebase providers and config ==="
git rm lib/providers/calendar_providers.dart \
       lib/providers/calendar_providers.g.dart \
       lib/providers/meal_assignment_providers.dart \
       lib/providers/meal_assignment_providers.g.dart \
       lib/providers/recipe_providers.dart \
       lib/providers/recipe_providers.g.dart \
       lib/providers/shopping_list_providers.dart \
       lib/providers/shopping_list_providers.g.dart \
       lib/providers/user_preferences_providers.dart \
       lib/providers/user_preferences_providers.g.dart \
       lib/firebase_options.dart

echo "=== Cleanup complete ==="
git status --short
