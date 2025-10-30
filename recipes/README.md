# Recipes Database Setup

This directory contains scripts and configuration for setting up versioned recipe databases in Firebase Firestore.

## Directory Structure

```
recipes/
├── v1/                          # Version 1 of recipes database
│   ├── setup_recipesv1.sh      # Shell script to set up recipesv1
│   ├── upload_recipes.dart     # Dart script to upload recipes to Firestore
│   └── README.md               # This file
```

## Setup

### Prerequisites
- Firebase CLI installed: `curl -sL https://firebase.tools | bash`
- Flutter/Dart environment configured
- Firebase project authenticated: `firebase login`
- Recipe titles extracted to `.tmp/recipe_dataset_titles.txt`

### Running Setup

From the `recipes/v1/` directory:

```bash
chmod +x setup_recipesv1.sh
./setup_recipesv1.sh
```

This will:
1. Verify Firebase project is set to `planmise`
2. Read recipe titles from extracted dataset
3. Upload recipes to Firestore collection `recipesv1/recipes`

## Firestore Structure

```
projectId (planmise)
└── recipesv1/                  # Versioned root collection
    └── recipes/                # Sub-collection (no version needed)
        ├── {recipeId1}/
        │   ├── title: string
        │   └── createdAt: timestamp
        ├── {recipeId2}/
        │   ├── title: string
        │   └── createdAt: timestamp
        └── ...
```

## Version Management

To create additional versions (e.g., `v2`):

1. Create new directory: `recipes/v2/`
2. Copy `setup_recipesv1.sh` and `upload_recipes.dart`
3. Update collection name from `recipesv1` to `recipesv2`
4. Update Dart class name and providers to use `V2` suffix
5. Create corresponding Dart repository: `RecipesV2Repository`

## Firebase Auth Integration

Users are assigned to recipe versions via custom auth claims:

```dart
// Example: Assign user to recipesv1
auth.setCustomUserClaims(uid, {'recipe_version': 'v1'});

// Example: Switch user to recipesv2
auth.setCustomUserClaims(uid, {'recipe_version': 'v2'});
```

App startup code:
```dart
final user = FirebaseAuth.instance.currentUser;
final recipesVersion = user?.getIdTokenResult().claims?['recipe_version'] ?? 'v1';

// Load appropriate repository based on version
final repository = switch(recipesVersion) {
  'v1' => RecipesV1Repository(firestore),
  'v2' => RecipesV2Repository(firestore),
  _ => RecipesV1Repository(firestore),
};
```

## Data Source Attribution

This dataset is sourced from:
- **Original Source**: Epicurious.com (Condé Nast)
- **Dataset Repo**: [recipe-dataset](https://github.com/josephrmartinez/recipe-dataset) by Joseph Martinez
- **License**: CC BY-SA 3.0 (Creative Commons Attribution-ShareAlike 3.0 Unported)

See `ATTRIBUTION.md` in the project root for full attribution details.
