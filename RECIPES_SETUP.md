# Recipes Database Setup Summary

## Overview
This setup enables a searchable, versioned recipe database in Firebase Firestore with support for A/B testing, gradual rollouts, and zero-downtime migrations.

## Files Created

### Attribution & Documentation
1. **ATTRIBUTION.md** - Top-level attribution file for CC BY-SA 3.0 licensed recipe dataset
   - Credits Joseph Martinez and Epicurious/Condé Nast
   - Contains full license information and links

2. **spec/attribution.md** - Specification for attribution display in app
   - Defines where and how attribution must be shown to users
   - Links to original data sources

3. **spec/FIREBASE.md** - Complete Firebase architecture specification
   - Detailed versioning strategy
   - A/B testing, gradual rollout, feature flags, and live debugging use cases
   - Collection structure examples
   - Deployment workflow and rollback strategy

4. **memory/FIREBASE.md** - Updated with architectural decisions
   - Quick reference for Firebase setup
   - Architectural principles
   - Use cases summary

5. **AGENTS.md** - Updated with Firebase section
   - Versioning requirements
   - Code generation patterns
   - Reference to detailed specs

### Recipe Database Infrastructure

6. **recipes/README.md** - Main documentation for recipes setup
   - Directory structure explanation
   - Prerequisites and setup instructions
   - Firestore collection structure
   - Version management guidance
   - Firebase auth integration examples

7. **recipes/v1/setup_recipesv1.sh** - Shell script to build Firestore import bundle and load it via Firebase CLI
   - Validates recipe file exists
   - Generates `.tmp/firestore_import.json`
   - Runs `firebase firestore:import`
   - Progress reporting

8. **recipes/v1/generate_firestore_import.py** - Python helper that builds Firestore import JSON
   - Reads recipe titles from `.tmp/recipe_dataset_titles.txt`
   - Creates import structure for `recipesv1`
   - Encodes lower-cased search helpers

## Data Source
- **Source File**: `.tmp/recipe_dataset_titles.txt` (13,496 recipes)
- **Original Source**: [recipe-dataset](https://github.com/josephrmartinez/recipe-dataset) by Joseph Martinez
- **Upstream Source**: Epicurious.com (Condé Nast)
- **License**: CC BY-SA 3.0 (Creative Commons Attribution-ShareAlike 3.0 Unported)

## Firestore Structure
```
planmise (project)
└── recipesv1/                 # Versioned root collection
    └── recipes/               # Sub-collection
        ├── {id1}/
        │   ├── title: string
        │   └── createdAt: timestamp
        ├── {id2}/
        │   ├── title: string
        │   └── createdAt: timestamp
        └── ...
```

## Next Steps

### 1. Run Setup
From `recipes/v1/`:
```bash
./setup_recipesv1.sh
```

### 2. Create App Repository Classes
In `meal_planner/lib/`:
```
repositories/recipes/
├── recipes_v1_repository.dart    # RecipesV1Repository class
└── recipes_v2_repository.dart    # (for future versions)

providers/recipes/
├── recipes_v1_provider.dart      # recipesV1Provider
└── recipes_v2_provider.dart      # (for future versions)
```

### 3. Implement User Version Routing
In app startup/initialization:
```dart
final recipe_version = user.getIdTokenResult().claims?['recipe_version'] ?? 'v1';
```

### 4. Add Attribution Screen
Create `lib/screens/attribution_screen.dart` per `spec/attribution.md`

### 5. Add Tests
```
test/repositories/recipes/
├── recipes_v1_repository_test.dart
└── recipes_v2_repository_test.dart

test/providers/recipes/
├── recipes_v1_provider_test.dart
└── recipes_v2_provider_test.dart
```

## Version Management
To add a new version (e.g., `recipesv2`):
1. Copy `recipes/v1/` to `recipes/v2/`
2. Update collection name from `recipesv1` to `recipesv2`
3. Update Dart class and file names to use `V2` suffix
4. Create new repository class: `RecipesV2Repository`
5. Create new provider: `recipesV2Provider`
6. Run setup script to populate new collection
7. Tag users with `recipe_version: "v2"` claim to switch them

## Architecture Highlights
- **Versioned Namespaces**: All resources include version number at outermost level
- **Firebase Auth Claims**: Users mapped to versions via custom auth claims
- **Zero-Downtime Migration**: Old and new versions coexist; switching is claim-based
- **Testing Support**: Unit tests for each version coexist in test suite
- **A/B Testing**: Subset of users can be tagged to test new version
- **Gradual Rollout**: Percentage of users can be increased over time
- **Live Debugging**: Special claim allows debug/dev versions of data
