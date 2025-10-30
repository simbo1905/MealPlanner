# Firebase Setup & Architecture

## Installation Status
- Firebase CLI tools installed: `firebase-tools@14.22.0`
- Authentication: Complete
- Project selected: `planmise`

## Usage
Firebase CLI is available for managing the project:
```bash
firebase --version
firebase projects:list
firebase use planmise
```

## Project
- Project ID: `planmise`
- Project Number: `1001077707255`

## Architectural Decisions

### Resource Versioning
All Firestore resources use versioned namespaces:
- Outermost container includes version: `recipesv1`, `recipesv2`, `usersv1`, etc.
- Enables simultaneous support for multiple data structures
- Allows A/B testing, gradual rollouts, and zero-downtime migrations

### Firebase Auth Custom Claims
User version assignment via custom auth attributes:
- Set custom claims on user auth object (e.g., `recipe_version: "v1"`)
- App reads claims at startup and routes to appropriate data source
- Claims controlled via Firebase console or Admin SDK
- Enables switching users between versions without app update

### Code Generation
Generated classes and providers must include version number:
- Classes: `RecipesV1Repository`, `RecipesV2Repository`
- Providers: `recipesV1Provider`, `recipesV2Provider`
- Files: `recipes_v1_provider.dart`, `recipes_v2_provider.dart`
- Repositories: `RecipesV1Repository`, `RecipesV2Repository`

### Testing Strategy
Unit tests span versions:
- Separate test files: `recipes_v1_test.dart`, `recipes_v2_test.dart`
- Both versions coexist in test suite
- Allows validation of migration and rollback paths
- Integration tests verify user claim → version mapping

## Use Cases
1. **A/B Testing**: Tag subset of users with new version via custom claim
2. **Gradual Rollout**: Increase percentage of users on new version over time
3. **Feature Flags**: Extend custom claims for experiment variants
4. **Live Debugging**: Create special claim for development/testing users
5. **Zero-Downtime Migration**: Keep old and new versions live during transition

## RecipesV1 Collection

### Structure
```
recipes_v1/{recipeId}
├── id: string (UUID)
├── title: string (original recipe name)
├── titleLower: string (lowercase for case-insensitive search)
├── titleTokens: array<string> (tokenized title for prefix matching)
├── ingredients: string (raw ingredient list)
├── instructions: string (cooking instructions)
├── ingredientNamesNormalized: array<string> (flattened normalized ingredients)
├── createdAt: timestamp
└── version: string ("v1")
```

### Access
- Read: All authenticated users
- Write: Admin only (via CLI/Admin SDK)
- Total: 13,496 recipes from Epicurious dataset

### Indexes
1. titleLower (ASC) + createdAt (DESC) - for title prefix search
2. ingredientNamesNormalized (ARRAY_CONTAINS) + createdAt (DESC) - for ingredient search

## User Favourites Collection

### Structure
```
user_favourites_v1/{userId}/recipes/{recipeId}
├── recipeId: string (reference to recipes_v1)
├── title: string (denormalized recipe title)
├── addedAt: timestamp
└── version: string ("v1")
```

### Access
- Read/Write: Only the owning user (auth.uid == userId)
- User isolation enforced by Firestore security rules

## Firebase Anonymous Auth
- Enabled for user identification
- Each user gets unique UID automatically
- Used for isolating user favorites data

See `spec/FIREBASE.md` for complete architecture documentation.
