# Firebase & Firestore Architecture Specification

## Overview
The application uses Firebase with versioned data resources to enable A/B testing, gradual rollouts, and simultaneous support for multiple data structure versions.

## Versioning Strategy

### 1. Resource Versioning
All resources (databases, collections, data structures) must include a version number in their outermost container that establishes a logical namespace:
- Examples: `recipesv1`, `recipesv2`, `usersv1`, `usersv2`
- Version number MUST be part of the resource identifier itself
- This allows the app to pivot to new data structures while maintaining old versions

### 2. Sub-resources
Elements within a versioned resource (indexes, tables within a schema, sub-collections) do NOT need additional version numbers:
- Example: `recipesv1/recipes` (not `recipesv1/recipesv1`)
- Example: `recipesv1/ingredients` (no additional version needed)

### 3. Code Generation
All generated classes and code that access versioned resources must use the matching version number:
- Class names: `RecipesV1Repository`, `RecipesV2Repository`
- File names: `recipes_v1_provider.dart`, `recipes_v2_provider.dart`
- Providers: `recipesV1Provider`, `recipesV2Provider`

## Firebase Auth Integration

### Custom User Attributes
Firebase Auth custom claims enable per-user version toggling:
- Custom claim: `recipe_version` → `"v1"` or `"v2"`
- Custom claim: `data_source` → experiment group identifier
- Claims set at user creation or during enrollment in A/B test

### User Mapping
- At app startup, read user's custom claims
- Map claims to specific repository/provider versions
- Load appropriate versioned data structure
- Enables zero-downtime version switching via Firebase console

## Use Cases

### A/B Testing New Data Sources
1. Create `recipesv2` collection with new data structure
2. Create `RecipesV2Repository` and `recipesV2Provider`
3. Tag subset of users with `recipe_version: "v2"` claim
4. App loads correct version based on claim
5. Metrics collected separately per version

### Gradual Rollout
1. Start with 5% of users on new version via custom claim
2. Monitor performance and errors
3. Gradually increase percentage through Firebase console
4. No app update required - data version controlled server-side

### Feature Flags & Experiments
1. Extend custom claims: `recipe_version`, `ui_variant`, `feature_flags`
2. Create corresponding versioned code paths
3. Swap screens, widgets, or landing pages based on claims
4. Example: Special debugging landing page for development users

### Live Debugging
1. Create special `recipe_version: "debug"` claim
2. Load debug version of recipes database
3. Use for live testing before general release
4. No impact on production users

## Implementation Pattern

```dart
// In providers
final recipesRepositoryProvider = Provider<RecipesRepository>((ref) {
  final version = ref.read(userVersionProvider);
  
  switch(version) {
    case 'v1':
      return RecipesV1Repository(firestore);
    case 'v2':
      return RecipesV2Repository(firestore);
    default:
      return RecipesV1Repository(firestore);
  }
});
```

## Testing Strategy

### Unit Tests Span Versions
- Create separate test suites: `recipes_v1_test.dart`, `recipes_v2_test.dart`
- Both versions coexist in test suite
- Allows validation of migration paths
- Tests can verify both old and new implementations

### Integration Tests
- Test user assignment to versions
- Test data access through versioned repositories
- Test switching between versions during session (if supported)

## Collection Structure

### Naming Convention
```
projectId
├── recipesv1/                          # Versioned root
│   ├── recipes/                        # Collection (no version)
│   │   ├── {recipeId}/
│   │   │   ├── title
│   │   │   ├── ingredients
│   │   │   └── instructions
│   └── ingredients/                    # Sub-collection (no version)
│       └── {ingredientId}/
├── recipesv2/                          # New version (different structure)
│   ├── dishes/                         # Different naming
│   │   └── {dishId}/
│   └── components/                     # Different sub-collection
├── usersv1/
│   └── {userId}/
└── usersv2/
    └── {userId}/
```

## Deployment Workflow

1. **Design**: Create versioned schema (e.g., `recipesv2`)
2. **Code**: Generate classes and repositories for new version
3. **Tests**: Write unit and integration tests alongside existing tests
4. **Data**: Populate new version's collections in Firestore
5. **Rollout**: Create custom claim for subset of users
6. **Monitor**: Track metrics per version
7. **Graduate**: Expand claim percentage or retire old version

## Rollback Strategy

- Keep previous version(s) live in Firestore
- Custom claims can revert users to previous version
- No data migration or code removal needed during rollback
- Version can be disabled simply by removing users' claims

## Monitoring & Metrics

- Track app startup time per version
- Monitor Firestore read/write costs per version
- Alert on errors specific to version
- A/B test conversion metrics per version
